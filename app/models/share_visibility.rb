#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class ShareVisibility < ActiveRecord::Base
  belongs_to :follower
  belongs_to :shareable, :polymorphic => :true

  scope :for_a_users_followers, lambda { |user|
    where(:follower_id => user.followers.map {|c| c.id})
  }
  scope :for_followers_of_a_person, lambda { |person|
    where(:follower_id => person.followers.map {|c| c.id})
  }

  validate :not_public

  # Perform a batch import, given a set of followers and a shareable
  # @note performs a bulk insert in mySQL; performs linear insertions in postgres
  # @param followers [Array<Follower>] Recipients
  # @param share [Shareable]
  # @return [void]
  def self.batch_import(follower_ids, share)
    return false unless ShareVisibility.new(:shareable_id => share.id, :shareable_type => share.class.to_s).valid?

    if AppConfig.postgres?
      follower_ids.each do |follower_id|
        ShareVisibility.find_or_create_by_follower_id_and_shareable_id_and_shareable_type(follower_id, share.id, share.class.base_class.to_s)
      end
    else
       new_share_visibilities_data = follower_ids.map do |follower_id|
        [follower_id, share.id, share.class.base_class.to_s]
      end
      ShareVisibility.import([:follower_id, :shareable_id, :shareable_type], new_share_visibilities_data)
    end
  end

  private
  def not_public
    if shareable.public?
      errors[:base] << "Cannot create visibility for a public object"
    end
  end
end
