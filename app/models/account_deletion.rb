#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class AccountDeletion < ActiveRecord::Base
  include Lygneo::Federated::Base


  belongs_to :person
  after_create :queue_delete_account

  attr_accessible :person

  xml_name :account_deletion
  xml_attr :lygneo_handle


  def person=(person)
    self[:lygneo_handle] = person.lygneo_handle
    self[:person_id] = person.id
  end

  def lygneo_handle=(lygneo_handle)
    self[:lygneo_handle] = lygneo_handle
    self[:person_id] ||= Person.find_by_lygneo_handle(lygneo_handle).id
  end

  def queue_delete_account
    Workers::DeleteAccount.perform_async(self.id)
  end

  def perform!
    self.dispatch if person.local?
    AccountDeleter.new(self.lygneo_handle).perform!
  end

  def subscribers(user)
    person.owner.follower_people.remote | Person.who_have_reshared_a_users_posts(person.owner).remote
  end

  def dispatch
    Postzord::Dispatcher.build(person.owner, self).post
  end

  def public?
    true
  end
end
