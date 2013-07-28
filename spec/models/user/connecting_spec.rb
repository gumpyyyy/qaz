#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe User::Connecting do

  let(:group) { alice.groups.first }
  let(:group1) { alice.groups.create(:name => 'other') }
  let(:person) { FactoryGirl.create(:person) }

  let(:group2) { eve.groups.create(:name => "group two") }

  let(:person_one) { FactoryGirl.create :person }
  let(:person_two) { FactoryGirl.create :person }
  let(:person_three) { FactoryGirl.create :person }

  describe 'disconnecting' do
    describe '#remove_follower' do
      it 'removed non mutual followers' do
        alice.share_with(eve.person, alice.groups.first)
        lambda {
          alice.remove_follower alice.follower_for(eve.person)
        }.should change {
          alice.followers(true).count
        }.by(-1)
      end

      it 'removes a followers receiving flag' do
        bob.followers.find_by_person_id(alice.person.id).should be_receiving
        bob.remove_follower(bob.follower_for(alice.person))
        bob.followers(true).find_by_person_id(alice.person.id).should_not be_receiving
      end
    end

    describe '#disconnected_by' do
      it 'calls remove follower' do
        bob.should_receive(:remove_follower).with(bob.follower_for(alice.person))
        bob.disconnected_by(alice.person)
      end

      it 'removes notitications' do
        alice.share_with(eve.person, alice.groups.first)
        Notifications::StartedSharing.where(:recipient_id => eve.id).first.should_not be_nil
        eve.disconnected_by(alice.person)
        Notifications::StartedSharing.where(:recipient_id => eve.id).first.should be_nil
      end
    end

    describe '#disconnect' do
      it 'calls remove follower' do
        follower = bob.follower_for(alice.person)

        bob.should_receive(:remove_follower).with(follower, {})
        bob.disconnect(follower)
      end

      it 'dispatches a retraction' do
        p = mock()
        Postzord::Dispatcher.should_receive(:build).and_return(p)
        p.should_receive(:post)

        bob.disconnect bob.follower_for(eve.person)
      end

      it 'should remove the follower from all groups they are in' do
        follower = alice.follower_for(bob.person)
        new_group = alice.groups.create(:name => 'new')
        alice.add_follower_to_group(follower, new_group)

        lambda {
          alice.disconnect(follower)
        }.should change(follower.groups(true), :count).from(2).to(0)
      end
    end
  end

  describe '#register_share_visibilities' do
    it 'creates post visibilites for up to 100 posts' do
      Post.stub_chain(:where, :limit).and_return([FactoryGirl.create(:status_message)])
      c = Follower.create!(:user_id => alice.id, :person_id => eve.person.id)
      expect{
        alice.register_share_visibilities(c)
      }.to change(ShareVisibility, :count).by(1)
    end
  end

  describe '#share_with' do
    it 'finds or creates a follower' do
      lambda {
        alice.share_with(eve.person, alice.groups.first)
      }.should change(alice.followers, :count).by(1)
    end

    it 'does not set mutual on intial share request' do
      alice.share_with(eve.person, alice.groups.first)
      alice.followers.find_by_person_id(eve.person.id).should_not be_mutual
    end

    it 'does set mutual on share-back request' do
      eve.share_with(alice.person, eve.groups.first)
      alice.share_with(eve.person, alice.groups.first)

      alice.followers.find_by_person_id(eve.person.id).should be_mutual
    end

    it 'adds a follower to an group' do
      follower = alice.followers.create(:person => eve.person)
      alice.followers.stub!(:find_or_initialize_by_person_id).and_return(follower)

      lambda {
        alice.share_with(eve.person, alice.groups.first)
      }.should change(follower.groups, :count).by(1)
    end

    it 'calls #register_share_visibilities with a follower' do
      eve.should_receive(:register_share_visibilities)
      eve.share_with(alice.person, eve.groups.first)
    end

    context 'dispatching' do
      it 'dispatches a request on initial request' do
        follower = alice.followers.new(:person => eve.person)
        alice.followers.stub!(:find_or_initialize_by_person_id).and_return(follower)

        follower.should_receive(:dispatch_request)
        alice.share_with(eve.person, alice.groups.first)
      end

      it 'dispatches a request on a share-back' do
        eve.share_with(alice.person, eve.groups.first)

        follower = alice.follower_for(eve.person)
        alice.followers.stub!(:find_or_initialize_by_person_id).and_return(follower)

        follower.should_receive(:dispatch_request)
        alice.share_with(eve.person, alice.groups.first)
      end

      it 'does not dispatch a request if follower already marked as receiving' do
        a2 = alice.groups.create(:name => "two")

        follower = alice.followers.create(:person => eve.person, :receiving => true)
        alice.followers.stub!(:find_or_initialize_by_person_id).and_return(follower)

        follower.should_not_receive(:dispatch_request)
        alice.share_with(eve.person, a2)
      end

      it 'posts profile' do
        m = mock()
        Postzord::Dispatcher.should_receive(:build).twice.and_return(m)
        m.should_receive(:post).twice
        alice.share_with(eve.person, alice.groups.first)
      end
    end

    it 'sets receiving' do
      alice.share_with(eve.person, alice.groups.first)
      alice.follower_for(eve.person).should be_receiving
    end

    it "should mark the corresponding notification as 'read'" do
      notification = FactoryGirl.create(:notification, :target => eve.person)

      Notification.where(:target_id => eve.person.id).first.unread.should be_true
      alice.share_with(eve.person, group)
      Notification.where(:target_id => eve.person.id).first.unread.should be_false
    end
  end
end
