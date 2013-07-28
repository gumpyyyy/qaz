#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class GroupPledge < ActiveRecord::Base

  belongs_to :group
  belongs_to :follower
  has_one :user, :through => :follower
  has_one :person, :through => :follower

  before_destroy do
    if self.follower && self.follower.groups.size == 1
      self.user.disconnect(self.follower)
    end
    true
  end

  def as_json(opts={})
    {
      :id => self.id,
      :person_id  => self.person.id,
      :follower_id => self.follower.id,
      :group_id  => self.group_id,
      :group_ids => self.follower.groups.map{|a| a.id}
    }
  end
end
