#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Mention < ActiveRecord::Base
  REGEX = /@\{([^;]+); ([^\}]+)\}/

  belongs_to :post
  belongs_to :person
  validates :post, :presence => true
  validates :person, :presence => true

  after_destroy :delete_notification

  def notify_recipient
    Rails.logger.info "event=mention_sent id=#{self.id} to=#{person.lygneo_handle} from=#{post.author.lygneo_handle}"
    Notification.notify(person.owner, self, post.author) unless person.remote?
  end

  def notification_type(*args)
    Notifications::Mentioned
  end

  def delete_notification
    Notification.where(:target_type => self.class.name, :target_id => self.id).delete_all
  end
end
