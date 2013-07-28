#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Stream::Group do
  describe '#groups' do
    it 'queries the user given initialized group ids' do
      alice = stub.as_null_object
      stream = Stream::Group.new(alice, [1,2,3])

      alice.groups.should_receive(:where)
      stream.groups
    end

    it "returns all the user's groups if no group ids are specified" do
      alice = stub.as_null_object
      stream = Stream::Group.new(alice, [])

      alice.groups.should_not_receive(:where)
      stream.groups
    end

    it 'filters groups given a user' do
      alice = stub(:groups => [stub(:id => 1)])
      alice.groups.stub(:where).and_return(alice.groups)
      stream = Stream::Group.new(alice, [1,2,3])

      stream.groups.should == alice.groups
    end
  end

  describe '#group_ids' do
    it 'maps ids from groups' do
      alice = stub.as_null_object
      groups = stub.as_null_object

      stream = Stream::Group.new(alice, [1,2])

      stream.should_receive(:groups).and_return(groups)
      groups.should_receive(:map)
      stream.group_ids
    end
  end

  describe '#posts' do
    before do
      @alice = stub.as_null_object
    end

    it 'calls visible posts for the given user' do
      stream = Stream::Group.new(@alice, [1,2])

      @alice.should_receive(:visible_shareables).and_return(stub.as_null_object)
      stream.posts
    end

    it 'is called with 3 types' do
      stream = Stream::Group.new(@alice, [1,2], :order => 'created_at')
      @alice.should_receive(:visible_shareables).with(Post, hash_including(:type=> ['StatusMessage', 'Reshare', 'ActivityStreams::Photo'])).and_return(stub.as_null_object)
      stream.posts
    end

    it 'respects ordering' do
      stream = Stream::Group.new(@alice, [1,2], :order => 'created_at')
      @alice.should_receive(:visible_shareables).with(Post, hash_including(:order => 'created_at DESC')).and_return(stub.as_null_object)
      stream.posts
    end

    it 'respects max_time' do
      stream = Stream::Group.new(@alice, [1,2], :max_time => 123)
      @alice.should_receive(:visible_shareables).with(Post, hash_including(:max_time => instance_of(Time))).and_return(stub.as_null_object)
      stream.posts
    end

    it 'passes for_all_groups to visible posts' do
      stream = Stream::Group.new(@alice, [1,2], :max_time => 123)
      all_groups = mock
      stream.stub(:for_all_groups?).and_return(all_groups)
      @alice.should_receive(:visible_shareables).with(Post, hash_including(:all_groups? => all_groups)).and_return(stub.as_null_object)
      stream.posts
    end
  end

  describe '#people' do
    it 'should call Person.all_from_groups' do
      class Person ; end

      alice = stub.as_null_object
      group_ids = [1,2,3]
      stream = Stream::Group.new(alice, [])

      stream.stub(:group_ids).and_return(group_ids)
      Person.should_receive(:unique_from_groups).with(stream.group_ids, alice).and_return(stub(:includes => :profile))
      stream.people
    end
  end

  describe '#group' do
    before do
      alice = stub.as_null_object
      @stream = Stream::Group.new(alice, [1,2])
    end

    it "returns an group if the stream is not for all the user's groups" do
      @stream.stub(:for_all_groups?).and_return(false)
      @stream.group.should_not be_nil
    end

    it "returns nothing if the stream is not for all the user's groups" do
      @stream.stub(:for_all_groups?).and_return(true)
      @stream.group.should be_nil
    end
  end

  describe 'for_all_groups?' do
    before do
      alice = stub.as_null_object
      alice.groups.stub(:size).and_return(2)
      @stream = Stream::Group.new(alice, [1,2])
    end

    it "is true if the count of group_ids is equal to the size of the user's group count" do
      @stream.group_ids.stub(:length).and_return(2)
      @stream.should be_for_all_groups
    end

    it "is false if the count of group_ids is not equal to the size of the user's group count" do
      @stream.group_ids.stub(:length).and_return(1)
      @stream.should_not be_for_all_groups
    end
  end

  describe 'shared behaviors' do
    before do
      @stream = Stream::Group.new(alice, alice.groups.map(&:id))
    end
    it_should_behave_like 'it is a stream'
  end
end
