#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Group do
  describe 'creation' do
    before do
      @name = alice.groups.first.name
    end

    it 'does not allow duplicate names' do
      lambda {
        invalid_group = alice.groups.create(:name => @name)
      }.should_not change(Group, :count)
    end

    it 'validates case insensitiveness on names' do
      lambda {
        invalid_group = alice.groups.create(:name => @name.titleize)
      }.should_not change(Group, :count)
    end

    it 'has a 20 character limit on names' do
      group = Group.new(:name => "this name is really too too too too too long")
      group.valid?.should == false
    end

    it 'is able to have other users as followers' do
      group = alice.groups.create(:name => 'losers')

      Follower.create(:user => alice, :person => eve.person, :groups => [group])
      group.followers.where(:person_id => alice.person.id).should be_empty
      group.followers.where(:person_id => eve.person.id).should_not be_empty
      group.followers.size.should == 1
    end

    it 'has a followers_visible? method' do
      alice.groups.first.followers_visible?.should be_true
    end
  end

  describe 'validation' do
    it 'has no uniqueness of name between users' do
      group = alice.groups.create(:name => "New Group")
      group2 = eve.groups.create(:name => group.name)
      group2.should be_valid
    end
  end
end
