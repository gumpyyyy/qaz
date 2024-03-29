#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AccountDeleter

  # Things that are not removed from the database:
  # - Comments
  # - Likes
  # - Messages
  # - NotificationActors
  #
  # Given that the User in question will be tombstoned, all of the
  # above will come from an anonomized account (via the UI).
  # The deleted user will appear as "Deleted Account" in
  # the interface.

  attr_accessor :person, :user

  def initialize(lygneo_handle)
    self.person = Person.where(:lygneo_handle => lygneo_handle).first
    self.user = self.person.owner
  end

  def perform!
    #person
    delete_standard_person_associations
    remove_conversation_visibilities
    remove_share_visibilities_on_persons_posts
    delete_followers_of_me
    tombstone_person_and_profile
    
    if self.user
      #user deletion methods
      remove_share_visibilities_on_followers_posts
      delete_standard_user_associations
      disassociate_invitations
      disconnect_followers
      tombstone_user
    end
  end

  #user deletions
  def normal_ar_user_associates_to_delete
    [:tag_followings, :invitations_to_me, :services, :groups, :user_preferences, :notifications, :blocks]
  end

  def special_ar_user_associations
    [:invitations_from_me, :person, :followers, :auto_follow_back_group]
  end

  def ignored_ar_user_associations
    [:followed_tags, :invited_by, :follower_people, :group_pledges, :ignored_people]
  end

  def delete_standard_user_associations
    normal_ar_user_associates_to_delete.each do |asso|
      self.user.send(asso).each{|model| model.delete}
    end
  end

  def delete_standard_person_associations
    normal_ar_person_associates_to_delete.each do |asso|
      self.person.send(asso).delete_all
    end
  end

  def disassociate_invitations
    user.invitations_from_me.each do |inv|
      inv.convert_to_admin!
    end
  end

  def disconnect_followers
    user.followers.destroy_all
  end

  # Currently this would get deleted due to the db foreign key constrainsts,
  # but we'll keep this method here for completeness
  def remove_share_visibilities_on_persons_posts
    ShareVisibility.for_followers_of_a_person(person).destroy_all
  end

  def remove_share_visibilities_on_followers_posts
    ShareVisibility.for_a_users_followers(user).destroy_all
  end

  def remove_conversation_visibilities
    ConversationVisibility.where(:person_id => person.id).destroy_all
  end

  def tombstone_person_and_profile
    self.person.lock_access!
    self.person.clear_profile!
  end

  def tombstone_user
    self.user.clear_account!
  end

  def delete_followers_of_me
    Follower.all_followers_of_person(self.person).destroy_all
  end
  
  def normal_ar_person_associates_to_delete
    [:posts, :photos, :mentions, :participations, :roles]
  end

  def ignored_or_special_ar_person_associations
    [:comments, :followers, :notification_actors, :notifications, :owner, :profile ]
  end
end
