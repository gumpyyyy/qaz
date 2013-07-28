#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Follower < ActiveRecord::Base
  belongs_to :user

  belongs_to :person
  validates :person, :presence => true
  
  delegate :name, :lygneo_handle, :guid, :first_name,
           to: :person, prefix: true

  has_many :group_pledges
  has_many :groups, :through => :group_pledges

  has_many :share_visibilities, :source => :shareable, :source_type => 'Post'
  has_many :posts, :through => :share_visibilities, :source => :shareable, :source_type => 'Post'

  validate :not_follower_for_self,
           :not_blocked_user,
           :not_follower_with_closed_account

  validates_presence_of :user
  validates_uniqueness_of :person_id, :scope => :user_id

  before_destroy :destroy_notifications

  scope :all_followers_of_person, lambda {|x| where(:person_id => x.id)}

    # follower.sharing is true when follower.person is sharing with follower.user
  scope :sharing, lambda {
    where(:sharing => true)
  }

  # follower.receiving is true when follower.user is sharing with follower.person
  scope :receiving, lambda {
    where(:receiving => true)
  }

  scope :for_a_stream, lambda {
    includes(:groups, :person => :profile).
        order('profiles.last_name ASC')
  }

  scope :only_sharing, lambda {
    sharing.where(:receiving => false)
  }

  def destroy_notifications
    Notification.where(:target_type => "Person",
                       :target_id => person_id,
                       :recipient_id => user_id,
                       :type => "Notifications::StartedSharing").delete_all
  end

  def dispatch_request
    request = self.generate_request
    Postzord::Dispatcher.build(self.user, request).post
    request
  end

  def generate_request
    Request.lygneo_initialize(:from => self.user.person,
                :to => self.person,
                :into => groups.first)
  end

  def receive_shareable(shareable)
    ShareVisibility.create!(:shareable_id => shareable.id, :shareable_type => shareable.class.base_class.to_s, :follower_id => self.id)
  end

  def followers
    people = Person.arel_table
    incoming_groups = Group.where(
      :user_id => self.person.owner_id,
      :followers_visible => true).joins(:followers).where(
        :followers => {:person_id => self.user.person_id}).select('groups.id')
    incoming_group_ids = incoming_groups.map{|a| a.id}
    similar_followers = Person.joins(:followers => :group_pledges).where(
      :group_pledges => {:group_id => incoming_group_ids}).where(people[:id].not_eq(self.user.person.id)).select('DISTINCT people.*')
  end

  def mutual?
    self.sharing && self.receiving
  end

  def in_group? group
    if group_pledges.loaded?
      group_pledges.detect{ |am| am.group_id == group.id }
    elsif groups.loaded?
      groups.detect{ |a| a.id == group.id }
    else
      GroupPledge.exists?(:follower_id => self.id, :group_id => group.id)
    end
  end

  private
  def not_follower_with_closed_account
    if person_id && person.closed_account?
      errors[:base] << 'Cannot be in follower with a closed account'
    end
  end

  def not_follower_for_self
    if person_id && person.owner == user
      errors[:base] << 'Cannot create self-follower'
    end
  end

  def not_blocked_user
    if user && user.blocks.where(:person_id => person_id).exists?
      errors[:base] << 'Cannot connect to an ignored user'
      false
    else
      true
    end
  end
end

