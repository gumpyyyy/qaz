#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

module Lygneo

  class Exporter
    def initialize(strategy)
      self.class.send(:include, strategy)
    end
  end

  module Exporters
    module XML
      def execute(user)
        builder = Nokogiri::XML::Builder.new do |xml|
          user_person_id = user.person_id
          xml.export {
            xml.user {
              xml.username user.username
              xml.serialized_private_key user.serialized_private_key

              xml.parent << user.person.to_xml
            }



            xml.groups {
              user.groups.each do |group|
                xml.group {
                  xml.name group.name

#                  xml.person_ids {
                    #group.person_ids.each do |id|
                      #xml.person_id id
                    #end
                  #}

                  xml.post_ids {
                    group.posts.find_all_by_author_id(user_person_id).each do |post|
                      xml.post_id post.id
                    end
                  }
                }
              end
            }

            xml.followers {
              user.followers.each do |follower|
              xml.follower {
                xml.user_id follower.user_id
                xml.person_id follower.person_id
                xml.person_guid follower.person_guid

                xml.groups {
                  follower.groups.each do |group|
                    xml.group {
                      xml.name group.name
                    }
                  end
                }
              }
              end
            }

            xml.posts {
              user.visible_shareables(Post).find_all_by_author_id(user_person_id).each do |post|
                #post.comments.each do |comment|
                #  post_doc << comment.to_xml
                #end

                xml.parent << post.to_xml
              end
            }

            xml.people {
              user.followers.each do |follower|
                person = follower.person
                xml.parent << person.to_xml

              end
            }
          }
        end

        # This is a hack.  Nokogiri interprets *.to_xml as a string.
        # we want to inject document objects, instead.  See lines: 25,35,40.
        # Solutions?
        CGI.unescapeHTML(builder.to_xml.to_s)
      end
    end
  end

end
