#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Request do
  before do
    @group = alice.groups.first
  end

  describe 'validations' do
    before do
      @request = Request.lygneo_initialize(:from => alice.person, :to => eve.person, :into => @group)
    end

    it 'is valid' do
      @request.sender.should == alice.person
      @request.recipient.should   == eve.person
      @request.group.should == @group
      @request.should be_valid
    end

    it 'is from a person' do
      @request.sender = nil
      @request.should_not be_valid
    end

    it 'is to a person' do
      @request.recipient = nil
      @request.should_not be_valid
    end

    it 'is not necessarily into an group' do
      @request.group = nil
      @request.should be_valid
    end

    it 'is not from an existing friend' do
      Follower.create(:user => eve, :person => alice.person, :groups => [eve.groups.first])
      @request.should_not be_valid
    end

    it 'is not to yourself' do
      @request = Request.lygneo_initialize(:from => alice.person, :to => alice.person, :into => @group)
      @request.should_not be_valid
    end
  end

  describe '#notification_type' do
    it 'returns request_accepted' do
      person = FactoryGirl.build:person

      request = Request.lygneo_initialize(:from => alice.person, :to => eve.person, :into => @group)
      alice.followers.create(:person_id => person.id)

      request.notification_type(alice, person).should == Notifications::StartedSharing
    end
  end

  describe '#subscribers' do
    it 'returns an array with to field on a request' do
      request = Request.lygneo_initialize(:from => alice.person, :to => eve.person, :into => @group)
      request.subscribers(alice).should =~ [eve.person]
    end
  end

  describe '#receive' do
    it 'creates a follower' do
      request = Request.lygneo_initialize(:from => alice.person, :to => eve.person, :into => @group)
      lambda{
        request.receive(eve, alice.person)
      }.should change{
        eve.followers(true).size
      }.by(1)
    end

    it 'sets mutual if a follower already exists' do
      alice.share_with(eve.person, alice.groups.first)

      lambda {
        Request.lygneo_initialize(:from => eve.person, :to => alice.person,
                                    :into => eve.groups.first).receive(alice, eve.person)
      }.should change {
        alice.followers.find_by_person_id(eve.person.id).mutual?
      }.from(false).to(true)

    end

    it 'sets sharing' do
      Request.lygneo_initialize(:from => eve.person, :to => alice.person,
                                  :into => eve.groups.first).receive(alice, eve.person)
      alice.follower_for(eve.person).should be_sharing
    end
    
    it 'shares back if auto_following is enabled' do
      alice.auto_follow_back = true
      alice.auto_follow_back_group = alice.groups.first
      alice.save
      
      Request.lygneo_initialize(:from => eve.person, :to => alice.person,
                                  :into => eve.groups.first).receive(alice, eve.person)
      
      eve.follower_for(alice.person).should be_sharing
    end
    
    it 'shares not back if auto_following is not enabled' do
      alice.auto_follow_back = false
      alice.auto_follow_back_group = alice.groups.first
      alice.save
      
      Request.lygneo_initialize(:from => eve.person, :to => alice.person,
                                  :into => eve.groups.first).receive(alice, eve.person)
      
      eve.follower_for(alice.person).should be_nil
    end
    
    it 'shares not back if already sharing' do
      alice.auto_follow_back = true
      alice.auto_follow_back_group = alice.groups.first
      alice.save
      
      follower = FactoryGirl.build:follower, :user => alice, :person => eve.person,
                                  :receiving => true, :sharing => false
      follower.save
      
      alice.should_not_receive(:share_with)
      
      Request.lygneo_initialize(:from => eve.person, :to => alice.person,
                                  :into => eve.groups.first).receive(alice, eve.person)
    end
  end

  context 'xml' do
    before do
      @request = Request.lygneo_initialize(:from => alice.person, :to => eve.person, :into => @group)
      @xml = @request.to_xml.to_s
    end

    describe 'serialization' do
      it 'produces valid xml' do
        @xml.should include alice.person.lygneo_handle
        @xml.should include eve.person.lygneo_handle
        @xml.should_not include alice.person.exported_key
        @xml.should_not include alice.person.profile.first_name
      end
    end

    context 'marshalling' do
      it 'produces a request object' do
        marshalled = Request.from_xml @xml

        marshalled.sender.should == alice.person
        marshalled.recipient.should == eve.person
        marshalled.group.should be_nil
      end
    end
  end
end
