
module Lygneo::Mentionable

  # regex for finding mention markup in plain text
  # ex.
  #   "message @{User Name; user@pod.net} text"
  #   will yield "User Name" and "user@pod.net"
  REGEX = /@\{([^;]+); ([^\}]+)\}/

  # class attribute that will be added to all mention html links
  PERSON_HREF_CLASS = "mention hovercardable"

  # takes a message text and returns the text with mentions in (html escaped)
  # plain text or formatted with html markup linking to user profiles.
  # default is html output.
  #
  # @param [String] text containing mentions
  # @param [Array<Person>] list of mentioned people
  # @param [Hash] formatting options
  # @return [String] formatted message
  def self.format(msg_text, people, *opts)
    people = [*people]
    fmt_msg = msg_text.to_s.gsub(REGEX) do |match_str|
      # for some reason gsub doesn't always produce MatchData...
      m = REGEX.match(match_str)
      person = people.detect{ |p| p.lygneo_handle == m[2] }

      ERB::Util.h(MentionsInternal.mention_link(person, m[1], *opts))
    end

    fmt_msg
  end

  # takes a message text and returns an array of people constructed from the
  # contained mentions
  #
  # @param [String] text containing mentions
  # @return [Array<Person>] array of people
  def self.people_from_string(msg_text)
    identifiers = msg_text.to_s.scan(REGEX).map do |match|
      match.last
    end

    return [] if identifiers.empty?
    Person.where(lygneo_handle: identifiers)
  end

  # takes a message text and converts mentions for people that are not in the
  # given groups to simple markdown links, leaving only mentions for people who
  # will actually be able to receive notifications for being mentioned.
  #
  # @param [String] message text
  # @param [User] group owner
  # @param [Mixed] array containing group ids or "all"
  # @return [String] message text with filtered mentions
  def self.filter_for_groups(msg_text, user, *groups)
    group_ids = MentionsInternal.get_group_ids(user, *groups)

    mentioned_ppl = people_from_string(msg_text)
    groups_ppl = GroupPledge.where(group_id: group_ids)
                                  .includes(:follower => :person)
                                  .map(&:person)

    filtered_msg = msg_text.to_s.gsub(REGEX) do |match_str|
      # for some reason gsub doesn't always produce MatchData...
      m = REGEX.match(match_str)
      person = mentioned_ppl.detect{ |p| p.lygneo_handle == m[2] }

      mention = match_str
      mention = MentionsInternal.profile_link(person, m[1]) unless groups_ppl.include?(person)

      mention
    end

    filtered_msg
  end

  private

  # inline module for namespacing
  module MentionsInternal
    extend ::PeopleHelper

    # output a formatted mention link as defined by the given options,
    # use the fallback name if the person is unavailable
    # @see Lygneo::Mentions#format
    #
    # @param [Person] AR Person
    # @param [String] fallback name
    # @param [Hash] formatting options
    def self.mention_link(person, fallback_name, *opts)
      return fallback_name unless person.present?

      if opts.include?(:plain_text)
        person.name
      else
        person_link(person, class: PERSON_HREF_CLASS)
      end
    end

    # output a markdown formatted link to the given person or the given fallback
    # string, in case the person is not present
    #
    # @param [Person] AR Person
    # @param [String] fallback name
    # @return [String] markdown person link
    def self.profile_link(person, fallback_name)
      return fallback_name unless person.present?

      "[#{person.name}](#{local_or_remote_person_path(person)})"
    end

    # takes a user and an array of group ids or an array containing "all" as
    # the first element. will do some checking on ids and return them in an array
    # in case of "all", returns an array with all the users group ids
    #
    # @param [User] owner of the groups
    # @param [Array] group ids or "all"
    # @return [Array] group ids
    def self.get_group_ids(user, *groups)
      return [] if groups.empty?

      if (!groups.first.kind_of?(Integer)) && groups.first.to_sym == :all
        return user.groups.pluck(:id)
      end

      ids = groups.select { |id| Integer(id) != nil } # only numeric

      #make sure they really belong to the user
      user.groups.where(id: ids).pluck(:id)
    end
  end

end
