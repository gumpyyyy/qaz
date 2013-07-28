#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module User::Connecting
  # This will create a follower on the side of the sharer and the sharee.
  # @param [Person] person The person to start sharing with.
  # @param [Group] group The group to add them to.
  # @return [Follower] The newly made follower for the passed in person.
  def share_with(person, group)
    follower = self.followers.find_or_initialize_by_person_id(person.id)
    return false unless follower.valid?

    unless follower.receiving?
      follower.dispatch_request
      follower.receiving = true
    end

    follower.groups << group
    follower.save

    if notification = Notification.where(:target_id => person.id).first
      notification.update_attributes(:unread=>false)
    end
    
    deliver_profile_update
    register_share_visibilities(follower)
    follower
  end

  # This puts the last 100 public posts by the passed in follower into the user's stream.
  # @param [Follower] follower
  # @return [void]
  def register_share_visibilities(follower)
    #should have select here, but proven hard to test
    posts = Post.where(:author_id => follower.person_id, :public => true).limit(100)
    p = posts.map do |post|
      ShareVisibility.new(:follower_id => follower.id, :shareable_id => post.id, :shareable_type => 'Post')
    end
    ShareVisibility.import(p) unless posts.empty?
    nil
  end

  def remove_follower(follower, opts={:force => false})
    posts = follower.posts.all

    if !follower.mutual? || opts[:force]
      follower.destroy
    else
      follower.update_attributes(:receiving => false)
    end
  end

  def disconnect(bad_follower, opts={})
    person = bad_follower.person
    Rails.logger.info("event=disconnect user=#{lygneo_handle} target=#{person.lygneo_handle}")
    retraction = Retraction.for(self)
    retraction.subscribers = [person]#HAX
    Postzord::Dispatcher.build(self, retraction).post

    GroupPledge.where(:follower_id => bad_follower.id).delete_all
    remove_follower(bad_follower, opts)
  end

  def disconnected_by(person)
    Rails.logger.info("event=disconnected_by user=#{lygneo_handle} target=#{person.lygneo_handle}")
    if follower = self.follower_for(person)
      remove_follower(follower)
    end
  end
end
