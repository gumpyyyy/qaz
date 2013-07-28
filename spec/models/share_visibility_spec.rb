#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe ShareVisibility do
  describe '.batch_import' do
    before do
      @post = FactoryGirl.create(:status_message, :author => alice.person)
      @follower = bob.follower_for(alice.person)
    end

    it 'returns false if share is public' do
      @post.public = true
      @post.save
      ShareVisibility.batch_import([@follower.id], @post).should be_false
    end

    it 'creates a visibility for each user' do
      lambda {
        ShareVisibility.batch_import([@follower.id], @post)
      }.should change {
        ShareVisibility.exists?(:follower_id => @follower.id, :shareable_id => @post.id, :shareable_type => 'Post')
      }.from(false).to(true)
    end

    it 'does not raise if a visibility already exists' do
      ShareVisibility.create!(:follower_id => @follower.id, :shareable_id => @post.id, :shareable_type => 'Post')
      lambda {
        ShareVisibility.batch_import([@follower.id], @post)
      }.should_not raise_error
    end

    context "scopes" do
      describe '.for_a_users_followers' do
        before do
          alice.post(:status_message, :text => "Hey", :to => alice.groups.first)
        end

        it 'searches for share visibilies for all users followers' do
          follower_ids = alice.followers.map{|c| c.id}
          ShareVisibility.for_a_users_followers(alice).should == ShareVisibility.where(:follower_id => follower_ids).all
        end
      end

      describe '.for_followers_of_a_person' do
        it 'searches for share visibilties generated by a person' do

          follower_ids = alice.person.followers.map{|c| c.id}
          
          ShareVisibility.for_followers_of_a_person(alice.person) == ShareVisibility.where(:follower_id => follower_ids).all
            
        end
      end
    end
  end
end
