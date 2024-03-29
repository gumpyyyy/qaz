#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Mention do
  describe "#notify_recipient" do
    before do
      @user = alice
      @group1 = @user.groups.create(:name => 'second_group')

    end

    it 'notifies the person being mentioned' do
      sm = @user.build_post(:status_message, :text => "hi @{#{bob.name}; #{bob.lygneo_handle}}", :to => @user.groups.first)
      Notification.should_receive(:notify).with(bob, anything(), sm.author)
      sm.receive(bob, alice.person)
    end

    it 'should not notify a user if they do not see the message' do
      Notification.should_not_receive(:notify).with(alice, anything(), bob.person)
      sm2 = bob.build_post(:status_message, :text => "stuff @{#{alice.name}; #{alice.lygneo_handle}}", :to => bob.groups.first)
      sm2.receive(eve, bob.person)
    end
  end

  describe '#notification_type' do
    it "returns 'mentioned'" do
     Mention.new.notification_type.should == Notifications::Mentioned
    end
  end

  describe 'after destroy' do
    it 'destroys a notification' do
      @user = alice
      @mentioned_user = bob

      @sm =  @user.post(:status_message, :text => "hi", :to => @user.groups.first)
      @m  = Mention.create!(:person => @mentioned_user.person, :post => @sm)
      @m.notify_recipient

      lambda{
        @m.destroy
      }.should change(Notification, :count).by(-1)
    end
  end
end

