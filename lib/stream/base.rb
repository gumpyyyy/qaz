class Stream::Base
  TYPES_OF_POST_IN_STREAM = ['StatusMessage', 'Reshare', 'ActivityStreams::Photo']

  attr_accessor :max_time, :order, :user, :publisher

  def initialize(user, opts={})
    self.user = user
    self.max_time = opts[:max_time]
    self.order = opts[:order]
    self.publisher = Publisher.new(self.user, publisher_opts)
  end

  #requied to implement said stream
  def link(opts={})
    'change me in lib/base_stream.rb!'
  end

  # @return [Boolean]
  def can_comment?(post)
    return true if post.author.local?
    post_is_from_follower?(post)
  end

  def post_from_group(post)
    []
  end

  # @return [String]
  def title
    'a title'
  end

  # @return [ActiveRecord::Relation<Post>]
  def posts
    Post.scoped
  end

  # @return [Array<Post>]
  def stream_posts
    self.posts.for_a_stream(max_time, order, self.user).tap do |posts|
      like_posts_for_stream!(posts) #some sql person could probably do this with joins.
    end
  end

  # @return [ActiveRecord::Association<Person>] AR association of people within stream's given groups
  def people
    people_ids = self.stream_posts.map{|x| x.author_id}
    Person.where(:id => people_ids).
      includes(:profile)
  end

  # @return [String] def followers_title 'change me in lib/base_stream.rb!'
  def followers_title
    'change me in lib/base_stream.rb!'
  end

  # @return [String]
  def followers_link
    Rails.application.routes.url_helpers.followers_path
  end

  # @return [Boolean]
  def for_all_groups?
    true
  end

  #NOTE: MBS bad bad methods the fact we need these means our views are foobared. please kill them and make them
  #private methods on the streams that need them
  def groups
    user.groups
  end

  # @return [Group] The first group in #groups
  def group
    groups.first
  end

  def group_ids
    groups.map{|x| x.id}
  end

  def max_time=(time_string)
    @max_time = Time.at(time_string.to_i) unless time_string.blank?
    @max_time ||= (Time.now + 1)
  end

  def order=(order_string)
    @order = order_string
    @order ||= 'created_at'
  end

  protected
  # @return [void]
  def like_posts_for_stream!(posts)
    return posts unless @user

    likes = Like.where(:author_id => @user.person_id, :target_id => posts.map(&:id), :target_type => "Post")

    like_hash = likes.inject({}) do |hash, like|
      hash[like.target_id] = like
      hash
    end

    posts.each do |post|
      post.user_like = like_hash[post.id]
    end
  end

  # @return [Hash]
  def publisher_opts
    {}
  end

  # Memoizes all Followers present in the Stream
  #
  # @return [Array<Follower>]
  def followers_in_stream
    @followers_in_stream ||= Follower.where(:user_id => user.id, :person_id => people.map{|x| x.id}).all
  end

  # @param post [Post]
  # @return [Boolean]
  def post_is_from_follower?(post)
    @can_comment_cache ||= {}
    @can_comment_cache[post.id] ||= followers_in_stream.find{|follower| follower.person_id == post.author.id}.present?
    @can_comment_cache[post.id] ||= (user.person_id == post.author_id)
    @can_comment_cache[post.id]
  end
end
