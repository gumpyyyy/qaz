#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User do
  before do
    @group = alice.groups.first
    @group1 = alice.groups.create(:name => 'other')
  end

  describe '#add_to_streams' do
    before do
      @params = {:text => "hey", :to => [@group.id, @group1.id]}
      @post = alice.build_post(:status_message, @params)
      @post.save
      @group_ids = @params[:to]
      @groups = alice.groups_from_ids(@group_ids)
    end

    it 'saves post into visible post ids' do
      lambda {
        alice.add_to_streams(@post, @groups)
      }.should change{alice.visible_shareables(Post, :by_members_of => @groups).length}.by(1)
      alice.visible_shareables(Post, :by_members_of => @groups).should include @post
    end

    it 'saves post into each group in group_ids' do
      alice.add_to_streams(@post, @groups)
      @group.reload.post_ids.should include @post.id
      @group1.reload.post_ids.should include @post.id
    end
  end

  describe '#groups_from_ids' do
    it 'returns a list of all valid groups a alice can post to' do
      group_ids = Group.all.map(&:id)
      alice.groups_from_ids(group_ids).map{|a| a}.should ==
        alice.groups.map{|a| a} #RSpec matchers ftw
    end
    it "lets you post to your own groups" do
      alice.groups_from_ids([@group.id]).should == [@group]
      alice.groups_from_ids([@group1.id]).should == [@group1]
    end
    it 'removes groups that are not yours' do
      alice.groups_from_ids(eve.groups.first.id).should == []
    end
  end

  describe '#build_post' do
    it 'sets status_message#text' do
      post = alice.build_post(:status_message, :text => "hey", :to => @group.id)
      post.text.should == "hey"
    end

    it 'does not save a status_message' do
      post = alice.build_post(:status_message, :text => "hey", :to => @group.id)
      post.should_not be_persisted
    end

    it 'does not save a photo' do
      post = alice.build_post(:photo, :user_file => uploaded_photo, :to => @group.id)
      post.should_not be_persisted
    end
  end

  describe '#update_post' do
    it 'should update fields' do
      photo = alice.post(:photo, :user_file => uploaded_photo, :text => "Old caption", :to => @group.id)
      update_hash = {:text => "New caption"}
      alice.update_post(photo, update_hash)

      photo.text.should match(/New/)
    end
  end
end
