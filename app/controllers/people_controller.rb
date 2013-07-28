#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PeopleController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :last_post]
  before_filter :redirect_if_tag_search, :only => [:index]

  respond_to :html, :except => [:tag_index]
  respond_to :json, :only => [:index, :show]
  respond_to :js, :only => [:tag_index]

  rescue_from ActiveRecord::RecordNotFound do
    render :file => Rails.root.join('public', '404').to_s,
           :format => :html, :layout => false, :status => 404
  end

  rescue_from Lygneo::AccountClosed do
    respond_to do |format|
      format.any { redirect_to :back, :notice => t("people.show.closed_account") }
      format.json { render :nothing => true, :status => 410 } # 410 GONE
    end
  end

  helper_method :search_query

  def index
    @group = :search
    limit = params[:limit] ? params[:limit].to_i : 15

    @people = Person.search(search_query, current_user)

    respond_to do |format|
      format.json do
        @people = @people.limit(limit)
        render :json => @people
      end

      format.any(:html, :mobile) do
        #only do it if it is an email address
        if lygneo_id?(search_query)
          @people =  Person.where(:lygneo_handle => search_query.downcase)
          if @people.empty?
            Webfinger.in_background(search_query)
            @background_query = search_query.downcase
          end
        end
        @people = @people.paginate(:page => params[:page], :per_page => 15)
        @hashes = hashes_for_people(@people, @groups)
      end
    end
  end

  def refresh_search
    @group = :search
    @people =  Person.where(:lygneo_handle => search_query.downcase)
    @answer_html = ""
    unless @people.empty?
      @hashes = hashes_for_people(@people, @groups)

      self.formats = self.formats + [:html]
      @answer_html = render_to_string :partial => 'people/person', :locals => @hashes.first
    end
    render :json => { :search_count => @people.count, :search_html => @answer_html }.to_json
  end


  def tag_index
    profiles = Profile.tagged_with(params[:name]).where(:searchable => true).select('profiles.id, profiles.person_id')
    @people = Person.where(:id => profiles.map{|p| p.person_id}).paginate(:page => params[:page], :per_page => 15)
    respond_with @people
  end

  # renders the persons user profile page
  def show
    @person = Person.find_from_guid_or_username(params)

    authenticate_user! if remote_profile_with_no_user_session?
    raise Lygneo::AccountClosed if @person.closed_account?

    @post_type = :all
    @group = :profile
    @stream = Stream::Person.new(current_user, @person, :max_time => max_time)
    @profile = @person.profile

    unless params[:format] == "json" # hovercard
      if current_user
        @block = current_user.blocks.where(:person_id => @person.id).first
        @follower = current_user.follower_for(@person)
        if @follower && !params[:only_posts]
          @followers_of_follower_count = @follower.followers.count
          @followers_of_follower = @follower.followers.limit(8)
        else
          @follower ||= Follower.new
        end
      end
    end

    respond_to do |format|
      format.all do
        respond_with @person, :locals => {:post_type => :all}
      end

      format.json { render :json => @stream.stream_posts.map { |p| LastThreeCommentsDecorator.new(PostPresenter.new(p, current_user)) }}
    end
  end

  # hovercards fetch some the persons public profile data via json and display
  # it next to the avatar image in a nice box
  def hovercard
    @person = Person.find_from_guid_or_username({:id => params[:person_id]})
    raise Lygneo::AccountClosed if @person.closed_account?

    respond_to do |format|
      format.all do
        redirect_to :action => "show", :id => params[:person_id]
      end

      format.json do
        render :json => HovercardPresenter.new(@person)
      end
    end
  end

  def last_post
    @person = Person.find_from_guid_or_username(params)
    last_post = Post.visible_from_author(@person, current_user).order('posts.created_at DESC').first
    redirect_to post_path(last_post)
  end

  def retrieve_remote
    if params[:lygneo_handle]
      Webfinger.in_background(params[:lygneo_handle], :single_group_form => true)
      render :nothing => true
    else
      render :nothing => true, :status => 422
    end
  end

  def followers
    @person = Person.find_by_guid(params[:person_id])
    if @person
      @follower = current_user.follower_for(@person)
      @group = :profile
      @followers_of_follower = @follower.followers.paginate(:page => params[:page], :per_page => (params[:limit] || 15))
      @hashes = hashes_for_people @followers_of_follower, @groups
    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
    end
  end

  # shows the dropdown list of groups the current user has set for the given person.
  # renders "thats you" in case the current user views himself
  def group_pledge_dropdown
    @person = Person.find_by_guid(params[:person_id])

    # you are not a follower of yourself...
    return render :text => I18n.t('people.person.thats_you') if @person == current_user.person

    @follower = current_user.follower_for(@person) || Follower.new
    render :partial => 'group_pledge_dropdown', :locals => {:follower => @follower, :person => @person, :hang => 'left'}
  end

  def redirect_if_tag_search
    if search_query.starts_with?('#')
      if search_query.length > 1

        redirect_to tag_path(:name => search_query.delete('#.'))
      else
        flash[:error] = I18n.t('tags.show.none', :name => search_query)
        redirect_to :back
      end
    end
  end

  private

  def hashes_for_people(people, groups)
    ids = people.map{|p| p.id}
    followers = {}
    Follower.unscoped.where(:user_id => current_user.id, :person_id => ids).each do |follower|
      followers[follower.person_id] = follower
    end

    people.map{|p|
      {:person => p,
        :follower => followers[p.id],
        :groups => groups}
    }
  end

  def search_query
    @search_query ||= params[:q] || params[:term] || ''
  end

  def lygneo_id?(query)
    !query.try(:match, /^(\w)*@([a-zA-Z0-9]|[-]|[.]|[:])*$/).nil?
  end

  def remote_profile_with_no_user_session?
    @person.try(:remote?) && !user_signed_in?
  end
end
