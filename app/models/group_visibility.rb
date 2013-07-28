#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class GroupVisibility < ActiveRecord::Base

  belongs_to :group
  validates :group, :presence => true

  belongs_to :shareable, :polymorphic => true
  validates :shareable, :presence => true

end
