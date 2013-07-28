require 'spec_helper'

describe 'deleteing your account' do
  context "user" do
    before do
      @bob2 = bob
      @person = @bob2.person
      @alices_post = alice.post(:status_message, :text => "@{@bob2 Grimn; #{@bob2.person.lygneo_handle}} you are silly", :to => alice.groups.find_by_name('generic'))

      @bobs_follower_ids = @bob2.followers.map {|c| c.id}

      #@bob2's own content
      @bob2.post(:status_message, :text => 'asldkfjs', :to => @bob2.groups.first)
      f = FactoryGirl.create(:photo, :author => @bob2.person)

      @group_vis = GroupVisibility.where(:group_id => @bob2.groups.map(&:id))

      #objects on post
      @bob2.like!(@alices_post)
      @bob2.comment!(@alices_post, "here are some thoughts on your post")

      #conversations
      create_conversation_with_message(alice, @bob2.person, "Subject", "Hey @bob2")

      #join tables
      @users_sv = ShareVisibility.where(:follower_id => @bobs_follower_ids).all
      @persons_sv = ShareVisibility.where(:follower_id => bob.person.followers.map(&:id)).all

      #user associated objects
      @prefs = []
      %w{mentioned liked reshared}.each do |pref|
        @prefs << @bob2.user_preferences.create!(:email_type => pref)
      end

      # notifications
      @notifications = []
      3.times do |n|
        @notifications << FactoryGirl.create(:notification, :recipient => @bob2)
      end

      # services
      @services = []
      3.times do |n|
        @services << FactoryGirl.create(:service, :user => @bob2)
      end

      # block
      @block = @bob2.blocks.create!(:person => eve.person)

      #authorization

      AccountDeleter.new(@bob2.person.lygneo_handle).perform!
      @bob2.reload
    end

    it "deletes all of the user's preferences" do
      UserPreference.where(:id => @prefs.map{|pref| pref.id}).should be_empty
    end

    it "deletes all of the user's notifications" do
      Notification.where(:id => @notifications.map{|n| n.id}).should be_empty
    end

    it "deletes all of the users's blocked users" do
      Block.where(:id => @block.id).should be_empty
    end

    it "deletes all of the user's services" do
      Service.where(:id => @services.map{|s| s.id}).should be_empty
    end

    it 'deletes all of @bob2s share visiblites' do
      ShareVisibility.where(:id => @users_sv.map{|sv| sv.id}).should be_empty
      ShareVisibility.where(:id => @persons_sv.map{|sv| sv.id}).should be_empty
    end

    it 'deletes all of @bob2s group visiblites' do
      GroupVisibility.where(:id => @group_vis.map(&:id)).should be_empty
    end

    it 'deletes all groups' do
      @bob2.groups.should be_empty
    end

    it 'deletes all user followers' do
      @bob2.followers.should be_empty
    end

    
    it "clears the account fields" do 
      @bob2.send(:clearable_fields).each do |field|
        @bob2.reload[field].should be_blank
      end
    end

    it_should_behave_like 'it removes the person associations'
  end

  context 'remote person' do
    before do
      @person = remote_raphael
      
      #followers
      @followers = @person.followers

      #posts
      @posts = (1..3).map do
        FactoryGirl.create(:status_message, :author => @person)
      end

      @persons_sv = @posts.each do |post|
        @followers.each do |follower|
          ShareVisibility.create!(:follower_id => follower.id, :shareable => post)
        end
      end

      #photos
      @photo = FactoryGirl.create(:photo, :author => @person)

      #mentions
      @mentions = 3.times do
        FactoryGirl.create(:mention, :person => @person)
      end

      #conversations
      create_conversation_with_message(alice, @person, "Subject", "Hey @bob2")

      AccountDeleter.new(@person.lygneo_handle).perform!
      @person.reload
    end

      it_should_behave_like 'it removes the person associations'
  end
end
