#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
require Rails.root.join('lib', 'lygneo', 'exporter')

describe Lygneo::Exporter do

  before do
    @user1 =  alice
    @user2 =  FactoryGirl.create(:user)
    @user3 =  bob

    @group  =  @user1.groups.first
    @group1 =  @user1.groups.create(:name => "Work")
    @group2 =  @user2.groups.create(:name => "Family")
    @group3 =  @user3.groups.first

    @status_message1 =  @user1.post(:status_message, :text => "One", :public => true, :to => @group1.id)
    @status_message2 =  @user1.post(:status_message, :text => "Two", :public => true, :to => @group1.id)
    @status_message3 =  @user2.post(:status_message, :text => "Three", :public => false, :to => @group2.id)
  end

  def exported
    Nokogiri::XML(Lygneo::Exporter.new(Lygneo::Exporters::XML).execute(@user1))
  end

  context '<user/>' do
    before do
      @user_xml = exported.xpath('//user').to_s
    end
    it 'includes a users private key' do
      @user_xml.to_s.should include @user1.serialized_private_key
    end
  end

  context '<groups/>' do

    it 'includes the post_ids' do
      groups_xml = exported.xpath('//groups').to_s
      groups_xml.should include @status_message1.id.to_s
      groups_xml.should include @status_message2.id.to_s
    end
  end

  context '<followers/>' do

    before do
      @user1.add_follower_to_group(@user1.follower_for(@user3.person), @group1)
      @user1.reload
    end

    let(:followers_xml) {exported.xpath('//followers').to_s}
    it "includes a person's guid" do
      followers_xml.should include @user3.person.guid
    end

    it "includes the names of all groups they are in" do
      #follower specific xml needs to be tested
      @user1.followers.find_by_person_id(@user3.person.id).groups.count.should > 0
      @user1.followers.find_by_person_id(@user3.person.id).groups.each { |group|
        followers_xml.should include group.name
      }
    end
  end

  context '<people/>' do
    let(:people_xml) {exported.xpath('//people').to_s}

    it 'includes their guid' do
      people_xml.should include @user3.person.guid
    end

    it 'includes their profile' do
      people_xml.should include @user3.person.profile.first_name
      people_xml.should include @user3.person.profile.last_name
    end

    it 'includes their public key' do
      people_xml.should include @user3.person.exported_key
    end

    it 'includes their lygneo handle' do
      people_xml.should include @user3.person.lygneo_handle
    end
  end

  context '<posts>' do
    let(:posts_xml) {exported.xpath('//posts').to_s}
    it "includes many posts' xml" do
      posts_xml.should include @status_message1.text
      posts_xml.should include @status_message2.text
      posts_xml.should_not include @status_message3.text
    end

    it "includes the post's created at time" do
      @status_message1.update_attribute(:created_at, Time.now - 1.day) # make sure they have different created at times

      doc = Nokogiri::XML::parse(posts_xml)
      created_at_text = doc.xpath('//posts/status_message').detect do |status|
        status.to_s.include?(@status_message1.guid)
      end.xpath('created_at').text
      
      Time.zone.parse(created_at_text).to_i.should == @status_message1.created_at.to_i
    end
  end
end
