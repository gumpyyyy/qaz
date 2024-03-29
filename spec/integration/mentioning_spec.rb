
require 'spec_helper'

module MentioningSpecHelpers
  def default_group
    @user1.groups.where(name: 'generic')
  end

  def text_mentioning(user)
    handle = user.lygneo_handle
    "this is a text mentioning @{Mention User ; #{handle}} ... have fun testing!"
  end

  def notifications_about_mentioning(user)
    Notifications::Mentioned.where(recipient_id: user.id)
  end

  def stream_for(user)
    stream = Stream::Multi.new(user)
    stream.posts
  end

  def users_connected?(user1, user2)
    user1.followers.where(person_id: user2.person).count > 0
  end
end


describe 'mentioning' do
  include MentioningSpecHelpers

  before do
    @user1 = FactoryGirl.create :user_with_group
    @user2 = FactoryGirl.create :user
    @user3 = FactoryGirl.create :user

    @user1.share_with(@user2.person, default_group)
  end

  # see: https://github.com/lygneo/lygneo/issues/4160
  it 'only mentions people that are in the target group' do
    users_connected?(@user1, @user2).should be_true
    users_connected?(@user1, @user3).should be_false

    status_msg = nil
    lambda do
      status_msg = @user1.post(:status_message, {text: text_mentioning(@user3), to: default_group})
    end.should change(Post, :count).by(1)

    status_msg.should_not be_nil
    status_msg.public?.should be_false
    status_msg.text.should include(@user3.name)

    notifications_about_mentioning(@user3).should be_empty
    stream_for(@user3).map { |item| item.id }.should_not include(status_msg.id)
  end

end
