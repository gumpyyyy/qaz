#   Copyright (c) 2010, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#the pont of this object is to centralize the simmilarities of Photo and post,
# as they used to be the same class
module Lygneo
  module Shareable
    def self.included(model)
      model.instance_eval do

        has_many :group_visibilities, :as => :shareable
        has_many :groups, :through => :group_visibilities

        has_many :share_visibilities, :as => :shareable
        has_many :followers, :through => :share_visibilities

        belongs_to :author, :class_name => 'Person'

        delegate :id, :name, :first_name, to: :author, prefix: true

        #scopes
        scope :all_public, where(:public => true, :pending => false)

        def self.owned_or_visible_by_user(user)
          self.joins("LEFT OUTER JOIN share_visibilities ON share_visibilities.shareable_id = posts.id AND share_visibilities.shareable_type = 'Post'").
               joins("LEFT OUTER JOIN followers ON followers.id = share_visibilities.follower_id").
               where(
                  Follower.arel_table[:user_id].eq(user.id).or(
                    self.arel_table[:public].eq(true).or(
                      self.arel_table[:author_id].eq(user.person_id)
                   )
                 )
               ).
               select("DISTINCT #{self.table_name}.*")
        end

        def self.for_visible_shareable_sql(max_time, order, limit = 15, types = Stream::Base::TYPES_OF_POST_IN_STREAM)
          by_max_time(max_time, order).
          where(:type => types).
          limit(limit)
        end

        def self.by_max_time(max_time, order='created_at')
          where("#{self.table_name}.#{order} < ?", max_time).order("#{self.table_name}.#{order} desc")
        end
      end
    end

    # @return [Integer]
    def update_reshares_counter
      self.class.where(:id => self.id).
        update_all(:reshares_count => self.reshares.count)
    end
  end
end
