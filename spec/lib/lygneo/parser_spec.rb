#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Lygneo::Parser do
  before do
    @user1 = alice
    @user2 = bob
    @user3 = eve

    @group1 = @user1.groups.first
    @group2 = @user2.groups.first
    @group3 = @user3.groups.first

    @person = FactoryGirl.create(:person)
  end

  describe "parsing compliant XML object" do
    it 'should be able to correctly parse comment fields' do
      post = @user1.post :status_message, :text => "hello", :to => @group1.id
      comment = FactoryGirl.create(:comment, :post => post, :author => @person, :lygneo_handle => @person.lygneo_handle, :text => "Freedom!")
      comment.delete
      xml = comment.to_lygneo_xml
      comment_from_xml = Lygneo::Parser.from_xml(xml)
      comment_from_xml.lygneo_handle.should ==  @person.lygneo_handle
      comment_from_xml.post.should == post
      comment_from_xml.text.should == "Freedom!"
      comment_from_xml.should_not be comment
    end
  end
end

