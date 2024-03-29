#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe Notifications::PrivateMessage do
    before do
      @user1 = alice
      @user2 = bob

      @create_hash = {
        :author => @user1.person,
        :participant_ids => [@user1.followers.first.person.id, @user1.person.id],
        :subject => 'cool stuff',
        :messages_attributes => [ {:author => @user1.person, :text => 'stuff'} ]
      }

      @cnv = Conversation.create(@create_hash)
      @msg = @cnv.messages.first
    end

    describe '#make_notifiaction' do
      it 'does not save the notification' do
        lambda{
          Notification.notify(@user2, @msg, @user1.person)
        }.should_not change(Notification, :count)
      end

      it 'does email the user' do
        opts = {
          :actors => [@user1.person],
          :recipient_id => @user2.id}

        n = Notifications::PrivateMessage.new(opts)
        Notifications::PrivateMessage.stub!(:make_notification).and_return(n)
        Notification.notify(@user2, @msg, @user1.person)
        n.stub!(:recipient).and_return @user2

        @user2.should_receive(:mail)
        n.email_the_user(@msg, @user1.person)
      end
      
      it 'increases user unread count - author user 1' do
        message = @cnv.messages.build(
          :text   => "foo bar",
          :author => @user1.person
        )
        message.save
        n = Notifications::PrivateMessage.make_notification(@user2, message, @user1.person, Notifications::PrivateMessage)
        
        ConversationVisibility.where(:conversation_id => message.reload.conversation.id,
            :person_id => @user2.person.id).first.unread.should == 1
      end
      
      it 'increases user unread count - author user 2' do
        message = @cnv.messages.build(
          :text   => "foo bar",
          :author => @user2.person
        )
        message.save
        n = Notifications::PrivateMessage.make_notification(@user1, message, @user2.person, Notifications::PrivateMessage)
        
        ConversationVisibility.where(:conversation_id => message.reload.conversation.id,
            :person_id => @user1.person.id).first.unread.should == 1
      end
      
    end
end
 
