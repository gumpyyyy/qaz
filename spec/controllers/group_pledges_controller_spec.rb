#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe GroupPledgesController do
  before do
    @group0  = alice.groups.first
    @group1  = alice.groups.create(:name => "another group")
    @group2  = bob.groups.first

    @follower = alice.follower_for(bob.person)
    alice.getting_started = false
    alice.save
    sign_in :user, alice
    @controller.stub(:current_user).and_return(alice)
    request.env["HTTP_REFERER"] = 'http://' + request.host
  end

  describe '#create' do
    before do
      @person = eve.person
    end

    it 'succeeds' do
      post :create,
        :format => :json,
        :person_id => bob.person.id,
        :group_id => @group1.id
      response.should be_success
    end

    it 'creates an group pledge' do
      lambda {
        post :create,
          :format => :json,
          :person_id => bob.person.id,
          :group_id => @group1.id
      }.should change{
        alice.follower_for(bob.person).group_pledges.count
      }.by(1)
    end

    it 'creates a follower' do
      #argggg why?
      alice.followers.reload
      lambda {
        post :create,
          :format => :json,
          :person_id => @person.id,
          :group_id => @group0.id
      }.should change{
        alice.followers.size
      }.by(1)
    end

    it 'failure flashes error' do
      alice.should_receive(:share_with).and_return(nil)
      post :create,
        :format => :json,
        :person_id => @person.id,
        :group_id => @group0.id
      flash[:error].should_not be_blank
    end

    it 'does not 500 on a duplicate key error' do
      params = {:format => :json, :person_id => @person.id, :group_id => @group0.id}
      post :create, params
      post :create, params
      response.status.should == 400
    end

    context 'json' do
      it 'returns a list of group ids for the person' do
        post :create,
        :format => :json,
        :person_id => @person.id,
        :group_id => @group0.id

        follower = @controller.current_user.follower_for(@person)
        response.body.should == follower.group_pledges.first.to_json
      end
    end
  end

  describe "#destroy" do
    it 'removes followers from an group' do
      pledge = alice.add_follower_to_group(@follower, @group1)
      delete :destroy, :format => :json, :id => pledge.id
      response.should be_success
      @group1.reload
      @group1.followers.include?(@follower).should be false
    end

    it 'does not 500 on an html request' do
      pledge = alice.add_follower_to_group(@follower, @group1)
      delete :destroy, :id => pledge.id
      response.should redirect_to :back
      @group1.reload
      @group1.followers.include?(@follower).should be false
    end

    it 'group pledge does not exist' do
      delete :destroy, :format => :json, :id => 123
      response.should_not be_success
      response.body.should include "Could not find the selected person in that group"
    end
  end
end
