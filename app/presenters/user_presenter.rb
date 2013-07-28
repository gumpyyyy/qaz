class UserPresenter
  attr_accessor :user, :groups_ids

  def initialize(user, groups_ids)
    self.user        = user
    self.groups_ids = groups_ids
  end

  def to_json(options = {})
    self.user.person.as_api_response(:backbone).update(
      { :notifications_count => notifications_count,
        :unread_messages_count => unread_messages_count,
        :admin => admin,
        :groups => groups,
        :services => services,
        :following_count => self.user.followers.receiving.count,
        :configured_services => self.configured_services,
      }
    ).to_json(options)
  end

  def services
    ServicePresenter.as_collection(user.services)
  end

  def configured_services
    user.services.map{|service| service.provider }
  end

  def groups
    @groups ||= begin
                   groups = GroupPresenter.as_collection(user.groups)
                   no_groups = self.groups_ids.empty?
                   groups.each{ |a| a[:selected] = no_groups || self.groups_ids.include?(a[:id].to_s) }
                 end
  end

  def notifications_count
    @notification_count ||= user.unread_notifications.count
  end

  def unread_messages_count
    @unread_message_count ||= user.unread_message_count
  end

  def admin
    user.admin?
  end
end
