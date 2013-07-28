#   Copyright (c) 2012, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#this module attempts to be what you need to mix into 
# base level federation objects that are not relayable, and not persistable
#assumes there is an author, author_id, id, 
module Lygneo
  module Federated
    module Shareable

      def self.included(model)
        model.instance_eval do
          #we are order dependant so you don't have to be!
          include Lygneo::Federated::Base
          include Lygneo::Federated::Shareable::InstanceMethods
          include Lygneo::Guid


          xml_attr :lygneo_handle
          xml_attr :public
          xml_attr :created_at
        end
      end

      module InstanceMethods
        def lygneo_handle
          read_attribute(:lygneo_handle) || self.author.lygneo_handle
        end

        def lygneo_handle=(author_handle)
          self.author = Person.where(:lygneo_handle => author_handle).first
          write_attribute(:lygneo_handle, author_handle)
        end

        # @param [User] user The user that is receiving this shareable.
        # @param [Person] person The person who dispatched this shareable to the
        # @return [void]
        def receive(user, person)
          #exists locally, but you dont know about it
          #does not exsist locally, and you dont know about it
          #exists_locally?
          #you know about it, and it is mutable
          #you know about it, and it is not mutable
          self.class.transaction do
            local_shareable = persisted_shareable

            if local_shareable && verify_persisted_shareable(local_shareable)
              self.receive_persisted(user, person, local_shareable)

            elsif !local_shareable
              self.receive_non_persisted(user, person)

            else
              Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.lygneo_handle} reason='update not from shareable owner' existing_shareable=#{self.id}")
              false
            end
          end
        end

        # The list of people that should receive this Shareable.
        #
        # @param [User] user The context, or dispatching user.
        # @return [Array<Person>] The list of subscribers to this shareable
        def subscribers(user)
          if self.public?
            user.follower_people
          else
            user.people_in_groups(user.groups_with_shareable(self.class, self.id))
          end
        end
         protected

        # @return [Shareable,void]
        def persisted_shareable
          self.class.where(:guid => self.guid).first
        end

        # @return [Boolean]
        def verify_persisted_shareable(persisted_shareable)
          persisted_shareable.author_id == self.author_id
        end

        def receive_persisted(user, person, local_shareable)
          known_shareable = user.find_visible_shareable_by_id(self.class.base_class, self.guid, :key => :guid)
          if known_shareable
            if known_shareable.mutable?
              known_shareable.update_attributes(self.attributes)
              true
            else
              Rails.logger.info("event=receive payload_type=#{self.class} update=true status=abort sender=#{self.lygneo_handle} reason=immutable") #existing_shareable=#{known_shareable.id}")
              false
            end
          else
            user.follower_for(person).receive_shareable(local_shareable)
            user.notify_if_mentioned(local_shareable)
            Rails.logger.info("event=receive payload_type=#{self.class} update=true status=complete sender=#{self.lygneo_handle}") #existing_shareable=#{local_shareable.id}")
            true
          end
        end

        def receive_non_persisted(user, person)
          if self.save
            user.follower_for(person).receive_shareable(self)
            user.notify_if_mentioned(self)
            Rails.logger.info("event=receive payload_type=#{self.class} update=false status=complete sender=#{self.lygneo_handle}")
            true
          else
            Rails.logger.info("event=receive payload_type=#{self.class} update=false status=abort sender=#{self.lygneo_handle} reason=#{self.errors.full_messages}")
            false
          end
        end
      end
    end
  end
end