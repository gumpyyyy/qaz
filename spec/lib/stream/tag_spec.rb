#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require Rails.root.join('spec', 'shared_behaviors', 'stream')

describe Stream::Tag do
  context 'with a user' do
    before do
      @stream = Stream::Tag.new(alice, "what")
      bob.post(:status_message, :text => "#not_what", :to => 'all')
    end

   it 'displays your own post' do
     my_post = alice.post(:status_message, :text => "#what", :to => 'all')
     @stream.posts.should == [my_post]
   end

   it "displays a friend's post" do
     other_post = bob.post(:status_message, :text => "#what", :to => 'all')
     @stream.posts.should == [other_post]
   end

   it 'displays a public post' do
     other_post = eve.post(:status_message, :text => "#what", :public => true, :to => 'all')
     @stream.posts.should == [other_post]
   end

   it 'displays a public post that was sent to no one' do
     stranger = FactoryGirl.create(:user_with_group)
     stranger_post = stranger.post(:status_message, :text => "#what", :public => true, :to => 'all')
     @stream.posts.should == [stranger_post]
   end

    it 'displays a post with a comment containing the tag search' do
      pending "this code is way too slow. need to re-implement in a way that doesn't suck"
      other_post = bob.post(:status_message, :text => "sup y'all", :to => 'all')
      FactoryGirl.create(:comment, :text => "#what", :post => other_post)
      @stream.posts.should == [other_post]
    end
  end

  context 'without a user' do
    before do
      @post = alice.post(:status_message, :text => "#what", :public => true, :to => 'all')
      alice.post(:status_message, :text => "#tagwhat", :public => true, :to => 'all')
      alice.post(:status_message, :text => "#what", :public => false, :to => 'all')
    end

    it "displays only public posts with the tag" do
      stream = Stream::Tag.new(nil, "what")
      stream.posts.should == [@post]
    end
  end

  describe "people" do
    it "assigns the set of people who authored a post containing the tag" do
      alice.post(:status_message, :text => "#what", :public => true, :to => 'all')
      stream = Stream::Tag.new(nil, "what")
      stream.people.should == [alice.person]
    end
  end

  describe 'tagged_people' do
    it "assigns the set of people who have that tag in their profile tags" do
      stream = Stream::Tag.new(bob, "whatevs")
      alice.profile.tag_string = "#whatevs"
      alice.profile.build_tags
      alice.profile.save!
      stream.tagged_people.should == [alice.person]
    end
  end

  describe 'case insensitivity' do
    before do
      @post_lc = alice.post(:status_message, :text => '#newhere', :public => true, :to => 'all')
      @post_uc = alice.post(:status_message, :text => '#NewHere', :public => true, :to => 'all')
      @post_cp = alice.post(:status_message, :text => '#NEWHERE', :public => true, :to => 'all')
    end

    it 'returns posts regardless of the tag case' do
      stream = Stream::Tag.new(nil, "newhere")
      stream.posts.should =~ [@post_lc, @post_uc, @post_cp]
    end
  end

  describe 'shared behaviors' do
    before do
      @stream = Stream::Tag.new(FactoryGirl.create(:user), "test")
    end
    it_should_behave_like 'it is a stream'
  end

  describe '#tag_name=' do
    it 'downcases the tag' do
      stream = Stream::Tag.new(nil, "WHAT")
      stream.tag_name.should == 'what'
    end

    it 'removes #es' do
      stream = Stream::Tag.new(nil, "#WHAT")
      stream.tag_name.should == 'what'
    end
  end

  describe "#publisher" do
    it 'creates a publisher with the tag prefill' do
      Publisher.should_receive(:new).with(anything(), anything)
      @stream = Stream::Tag.new(alice, "what")
    end
  end
end
