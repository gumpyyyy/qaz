#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe GroupsController do
  before do
    alice.getting_started = false
    alice.save
    sign_in :user, alice
    @alices_group_1 = alice.groups.where(:name => "generic").first
    @alices_group_2 = alice.groups.create(:name => "another group")

    @controller.stub(:current_user).and_return(alice)
    request.env["HTTP_REFERER"] = 'http://' + request.host
  end


  describe "#new" do
    it "renders a remote form if remote is true" do
      get :new, "remote" => "true"
      response.should be_success
      response.body.should =~ /#{Regexp.escape('data-remote="true"')}/
    end
    it "renders a non-remote form if remote is false" do
      get :new, "remote" => "false"
      response.should be_success
      response.body.should_not =~ /#{Regexp.escape('data-remote="true"')}/
    end
    it "renders a non-remote form if remote is missing" do
      get :new
      response.should be_success
      response.body.should_not =~ /#{Regexp.escape('data-remote="true"')}/
    end
  end

  describe "#show" do
    it "succeeds" do
      get :show, 'id' => @alices_group_1.id.to_s
      response.should be_redirect
    end
    it 'redirects on an invalid id' do
      get :show, 'id' => 4341029835
      response.should be_redirect
    end
  end

  describe "#create" do
    context "with valid params" do
      it "creates an group" do
        alice.groups.count.should == 2
        post :create, "group" => {"name" => "new group"}
        alice.reload.groups.count.should == 3
      end
      it "redirects to the group's follower page" do
        post :create, "group" => {"name" => "new group"}
        response.should redirect_to(followers_path(:a_id => Group.find_by_name("new group").id))
      end

      context "with person_id param" do
        it "creates a follower if one does not already exist" do
          lambda {
            post :create, :format => 'js', :group => {:name => "new", :person_id => eve.person.id}
          }.should change {
            alice.followers.count
          }.by(1)
        end

        it "adds a new follower to the new group" do
          post :create, :format => 'js', :group => {:name => "new", :person_id => eve.person.id}
          alice.groups.find_by_name("new").followers.count.should == 1
        end

        it "adds an existing follower to the new group" do
          post :create, :format => 'js', :group => {:name => "new", :person_id => bob.person.id}
          alice.groups.find_by_name("new").followers.count.should == 1
        end
      end
    end

    context "with invalid params" do
      it "does not create an group" do
        alice.groups.count.should == 2
        post :create, "group" => {"name" => ""}
        alice.reload.groups.count.should == 2
      end
      it "goes back to the page you came from" do
        post :create, "group" => {"name" => ""}
        response.should redirect_to(:back)
      end
    end
  end

  describe "#update" do
    before do
      @alices_group_1 = alice.groups.create(:name => "Bruisers")
    end

    it "doesn't overwrite random attributes" do
      new_user = FactoryGirl.create :user
      params = {"name" => "Bruisers"}
      params[:user_id] = new_user.id
      put('update', :id => @alices_group_1.id, "group" => params)
      Group.find(@alices_group_1.id).user_id.should == alice.id
    end

    it "should return the name and id of the updated item" do
      params = {"name" => "Bruisers"}
      put('update', :id => @alices_group_1.id, "group" => params)
      response.body.should == { :id => @alices_group_1.id, :name => "Bruisers" }.to_json
    end
  end

  describe '#edit' do
    before do
      eve.profile.first_name = eve.profile.last_name = nil
      eve.profile.save
      eve.save

      @zed = FactoryGirl.create(:user_with_group, :username => "zed")
      @zed.profile.first_name = "zed"
      @zed.profile.save
      @zed.save
      @katz = FactoryGirl.create(:user_with_group, :username => "katz")
      @katz.profile.first_name = "katz"
      @katz.profile.save
      @katz.save

      connect_users(alice, @alices_group_2, eve, eve.groups.first)
      connect_users(alice, @alices_group_2, @zed, @zed.groups.first)
      connect_users(alice, @alices_group_1, @katz, @katz.groups.first)
    end

    it 'renders' do
      get :edit, :id => @alices_group_1.id
      response.should be_success
    end

    it 'assigns the followers in alphabetical order with people in groups first' do
      get :edit, :id => @alices_group_2.id
      assigns[:followers].map(&:id).should == [alice.follower_for(eve.person), alice.follower_for(@zed.person), alice.follower_for(bob.person), alice.follower_for(@katz.person)].map(&:id)
    end

    it 'assigns all the followers if noone is there' do
      alices_group_3 = alice.groups.create(:name => "group 3")

      get :edit, :id => alices_group_3.id
      assigns[:followers].map(&:id).should == [alice.follower_for(bob.person), alice.follower_for(eve.person), alice.follower_for(@katz.person), alice.follower_for(@zed.person)].map(&:id)
    end

    it 'eager loads the group pledges for all the followers' do
      get :edit, :id => @alices_group_2.id
      assigns[:followers].each do |c|
        c.group_pledges.loaded?.should be_true
      end
    end
  end

  describe "#toggle_follower_visibility" do
    it 'sets followers visible' do
      @alices_group_1.followers_visible = false
      @alices_group_1.save

      get :toggle_follower_visibility, :format => 'js', :group_id => @alices_group_1.id
      @alices_group_1.reload.followers_visible.should be_true
    end

    it 'sets followers hidden' do
      @alices_group_1.followers_visible = true
      @alices_group_1.save

      get :toggle_follower_visibility, :format => 'js', :group_id => @alices_group_1.id
      @alices_group_1.reload.followers_visible.should be_false
    end
  end
end
