#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe FollowersController do
  before do
    sign_in :user, bob
    @controller.stub(:current_user).and_return(bob)
  end

  describe '#sharing' do
    it "succeeds" do
      get :sharing
      response.should be_success
    end

    it 'eager loads the groups' do
      get :sharing
      assigns[:followers].first.group_pledges.loaded?.should be_true
    end

    it "assigns only the people sharing with you with 'share_with' flag" do
      get :sharing, :id => 'share_with'
      assigns[:followers].to_set.should == bob.followers.sharing.to_set
    end
  end

  describe '#index' do
    context 'format mobile' do
      it "succeeds" do
        get :index, :format => 'mobile'
        response.should be_success
      end
    end

    context 'format html' do
      it "succeeds" do
        get :index
        response.should be_success
      end

      it "assigns followers" do
        get :index
        followers = assigns(:followers)
        followers.to_set.should == bob.followers.to_set
      end

      it "shows only followers a user is sharing with" do
        follower = bob.followers.first
        follower.update_attributes(:sharing => false)

        get :index, :set => "mine"
        followers = assigns(:followers)
        followers.to_set.should == bob.followers.receiving.to_set
      end

      it "shows all followers (sharing and receiving)" do
        follower = bob.followers.first
        follower.update_attributes(:sharing => false)

        get :index, :set => "all"
        followers = assigns(:followers)
        followers.to_set.should == bob.followers.to_set
      end
    end

    context 'format json' do
      it 'assumes all groups if none are specified' do
        get :index, :format => 'json'
        assigns[:people].map(&:id).should =~ bob.followers.map { |c| c.person.id }
        response.should be_success
      end

      it 'returns the followers for multiple groups' do
        get :index, :group_ids => bob.group_ids, :format => 'json'
        assigns[:people].map(&:id).should =~ bob.followers.map { |c| c.person.id }
        response.should be_success
      end

      it 'does not return duplicate followers' do
        group = bob.groups.create(:name => 'hilarious people')
        group.followers << bob.follower_for(eve.person)
        get :index, :format => 'json', :group_ids => bob.group_ids
        assigns[:people].map { |p| p.id }.uniq.should == assigns[:people].map { |p| p.id }
        assigns[:people].map(&:id).should =~ bob.followers.map { |c| c.person.id }
      end
    end
  end

  describe '#spotlight' do
    it 'succeeds' do
      get :spotlight
      response.should be_success
    end

    it 'gets queries for users in the app config' do
      Role.add_spotlight(alice.person)

      get :spotlight
      assigns[:people].should == [alice.person]
    end
  end
end
