#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Follower do
  describe 'group_pledges' do
    it 'deletes dependent group pledges' do
      lambda{
        alice.follower_for(bob.person).destroy
      }.should change(GroupPledge, :count).by(-1)
    end
  end

  context 'validations' do
    let(:follower){Follower.new}

    it 'requires a user' do
      follower.valid?
      follower.errors.full_messages.should include "User can't be blank"
    end

    it 'requires a person' do
      follower.valid?
      follower.errors.full_messages.should include "Person can't be blank"
    end

    it 'ensures user is not making a follower for himself' do
      follower.person = alice.person
      follower.user = alice

      follower.valid?
      follower.errors.full_messages.should include "Cannot create self-follower"
    end

    it 'validates uniqueness' do
      person = FactoryGirl.create(:person)

      follower2 = alice.followers.create(:person=>person)
      follower2.should be_valid

      follower.user = alice
      follower.person = person
      follower.should_not be_valid
    end

    it "validates that the person's account is not closed" do
      person = FactoryGirl.create(:person, :closed_account => true)

      follower = alice.followers.new(:person=>person)

      follower.should_not be_valid
      follower.errors.full_messages.should include "Cannot be in follower with a closed account"
    end
  end

  context 'scope' do
    describe 'sharing' do
      it 'returns followers with sharing true' do
        lambda {
          alice.followers.create!(:sharing => true, :person => FactoryGirl.create(:person))
          alice.followers.create!(:sharing => false, :person => FactoryGirl.create(:person))
        }.should change{
          Follower.sharing.count
        }.by(1)
      end
    end

    describe 'receiving' do
      it 'returns followers with sharing true' do
        lambda {
          alice.followers.create!(:receiving => true, :person => FactoryGirl.build(:person))
          alice.followers.create!(:receiving => false, :person => FactoryGirl.build(:person))
        }.should change{
          Follower.receiving.count
        }.by(1)
      end
    end

    describe 'only_sharing' do
      it 'returns followers with sharing true and receiving false' do
        lambda {
          alice.followers.create!(:receiving => true, :sharing => true, :person => FactoryGirl.build(:person))
          alice.followers.create!(:receiving => false, :sharing => true, :person => FactoryGirl.build(:person))
          alice.followers.create!(:receiving => false, :sharing => true, :person => FactoryGirl.build(:person))
          alice.followers.create!(:receiving => true, :sharing => false, :person => FactoryGirl.build(:person))
        }.should change{
          Follower.receiving.count
        }.by(2)
      end
    end
    
    describe "all_followers_of_person" do
      it 'returns all followers where the person is the passed in person' do
        person = FactoryGirl.create(:person)
        follower1 = FactoryGirl.create(:follower, :person => person)
        follower2 = FactoryGirl.create(:follower)
        followers = Follower.all_followers_of_person(person)
        followers.should == [follower1]
      end
    end
  end

  describe '#followers' do
    before do
      @alice = alice
      @bob = bob
      @eve = eve
      @bob.groups.create(:name => 'next')
      @bob.groups(true)

      @original_group = @bob.groups.where(:name => "generic").first
      @new_group = @bob.groups.where(:name => "next").first

      @people1 = []
      @people2 = []

      1.upto(5) do
        person = FactoryGirl.build(:person)
        @bob.followers.create(:person => person, :groups => [@original_group])
        @people1 << person
      end
      1.upto(5) do
        person = FactoryGirl.build(:person)
        @bob.followers.create(:person => person, :groups => [@new_group])
        @people2 << person
      end
    #eve <-> bob <-> alice
    end

    context 'on a follower for a local user' do
      before do
        @alice.reload
        @alice.groups.reload
        @follower = @alice.follower_for(@bob.person)
      end

      it "returns the target local user's followers that are in the same group" do
        @follower.followers.map{|p| p.id}.should =~ [@eve.person].concat(@people1).map{|p| p.id}
      end

      it 'returns nothing if followers_visible is false in that group' do
        @original_group.followers_visible = false
        @original_group.save
        @follower.followers.should == []
      end

      it 'returns no duplicate followers' do
        [@alice, @eve].each {|c| @bob.add_follower_to_group(@bob.follower_for(c.person), @bob.groups.last)}
        follower_ids = @follower.followers.map{|p| p.id}
        follower_ids.uniq.should == follower_ids
      end
    end

    context 'on a follower for a remote user' do
      before do
        @follower = @bob.follower_for @people1.first
      end
      it 'returns an empty array' do
        @follower.followers.should == []
      end
    end
  end

  context 'requesting' do
    before do
      @follower = Follower.new
      @user = FactoryGirl.build(:user)
      @person = FactoryGirl.build(:person)

      @follower.user = @user
      @follower.person = @person
    end

    describe '#generate_request' do
      it 'makes a request' do
        @follower.stub(:user).and_return(@user)
        request = @follower.generate_request

        request.sender.should == @user.person
        request.recipient.should == @person
      end
    end

    describe '#dispatch_request' do
      it 'pushes to people' do
        @follower.stub(:user).and_return(@user)
        m = mock()
        m.should_receive(:post)
        Postzord::Dispatcher.should_receive(:build).and_return(m)
        @follower.dispatch_request
      end
    end
  end

  describe "#not_blocked_user" do
    before do
      @follower = alice.follower_for(bob.person)
    end

    it "is called on validate" do
      @follower.should_receive(:not_blocked_user)
      @follower.valid?
    end

    it "adds to errors if potential follower is blocked by user" do
      person = eve.person
      block = alice.blocks.create(:person => person)
      bad_follower = alice.followers.create(:person => person)

      bad_follower.send(:not_blocked_user).should be_false
    end

    it "does not add to errors" do
      @follower.send(:not_blocked_user).should be_true
    end
  end
end
