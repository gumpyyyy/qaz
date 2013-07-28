#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class Stream::Group < Stream::Base

  # @param user [User]
  # @param inputted_group_ids [Array<Integer>] Ids of groups for given stream
  # @param group_ids [Array<Integer>] Groups this stream is responsible for
  # @opt max_time [Integer] Unix timestamp of stream's post ceiling
  # @opt order [String] Order of posts (i.e. 'created_at', 'updated_at')
  # @return [void]
  def initialize(user, inputted_group_ids, opts={})
    super(user, opts)
    @inputted_group_ids = inputted_group_ids
  end

  # Filters groups given the stream's group ids on initialization and the user.
  # Will disclude groups from inputted group ids if user is not associated with their
  # target groups.
  #
  # @return [ActiveRecord::Association<Group>] Filtered groups given the stream's user
  def groups
    @groups ||= lambda do
      a = user.groups
      a = a.where(:id => @inputted_group_ids) if @inputted_group_ids.any?
      a
    end.call
  end

  # Maps ids into an array from #groups
  #
  # @return [Array<Integer>] Group ids
  def group_ids
    @group_ids ||= groups.map { |a| a.id }
  end

  # @return [ActiveRecord::Association<Post>] AR association of posts
  def posts
    # NOTE(this should be something like Post.all_for_stream(@user, group_ids, {}) that calls visible_shareables
    @posts ||= user.visible_shareables(Post, :all_groups? => for_all_groups?,
                                             :by_members_of => group_ids,
                                             :type => TYPES_OF_POST_IN_STREAM,
                                             :order => "#{order} DESC",
                                             :max_time => max_time
                   )
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given groups
  def people
    @people ||= Person.unique_from_groups(group_ids, user).includes(:profile)
  end

  # @return [String] URL
  def link(opts={})
    Rails.application.routes.url_helpers.groups_path(opts)
  end

  # The first group in #groups, given the stream is not for all groups, or #groups size is 1
  # @note groups.first is used for mobile. NOTE(this is a hack and should be fixed)
  # @return [Group,Symbol]
  def group
    if !for_all_groups? || groups.size == 1
      groups.first
    end
  end

  # The title that will display at the top of the stream's
  # publisher box.
  #
  # @return [String]
  def title
    if self.for_all_groups?
      I18n.t('streams.groups.title')
    else
      self.groups.to_sentence
    end
  end

  # Determine whether or not the stream is displaying across
  # all of the user's groups.
  #
  # @return [Boolean]
  def for_all_groups?
    @all_groups ||= group_ids.length == user.groups.size
  end

  # Provides a translated title for followers box on the right pane.
  #
  # @return [String]
  def followers_title
    if self.for_all_groups? || self.group_ids.size > 1
      I18n.t('_followers')
    else
     "#{self.group.name} (#{self.people.size})"
    end
  end

  # Provides a link to the user to the followers page that corresponds with
  # the stream's active groups.
  #
  # @return [String] Link to followers
  def followers_link
    if for_all_groups? || group_ids.size > 1
      Rails.application.routes.url_helpers.followers_path
    else
      Rails.application.routes.url_helpers.followers_path(:a_id => group.id)
    end
  end

  # This is perfomance optimization, as everyone in your group stream you have
  # a follower.
  #
  # @param post [Post]
  # @return [Boolean]
  def can_comment?(post)
    true
  end
end
