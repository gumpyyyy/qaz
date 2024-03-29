class ConversationsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :mobile, :json, :js

  def index
    @conversations = Conversation.joins(:conversation_visibilities).where(
      :conversation_visibilities => {:person_id => current_user.person_id}).paginate(
      :page => params[:page], :per_page => 15, :order => 'updated_at DESC')

    @visibilities = ConversationVisibility.where(:person_id => current_user.person_id).paginate(
      :page => params[:page], :per_page => 15, :order => 'updated_at DESC')
      
    @conversation = Conversation.joins(:conversation_visibilities).where(
      :conversation_visibilities => {:person_id => current_user.person_id, :conversation_id => params[:conversation_id]}).first

    @unread_counts = {}
    @visibilities.each { |v| @unread_counts[v.conversation_id] = v.unread }
    
    @first_unread_message_id = @conversation.try(:first_unread_message, current_user).try(:id)

    @authors = {}
    @conversations.each { |c| @authors[c.id] = c.last_author }

    respond_with do |format|
      format.html
      format.json { render :json => @conversations, :status => 200 }
    end
  end

  def create
    # Can't split nil
    if params[:follower_ids]
      person_ids = Follower.where(:id => params[:follower_ids].split(',')).map(&:person_id)
    end

    params[:conversation][:participant_ids] = [*person_ids] | [current_user.person_id]
    params[:conversation][:author] = current_user.person
    message_text = params[:conversation].delete(:text)
    params[:conversation][:messages_attributes] = [ {:author => current_user.person, :text => message_text }]

    @response = {}
    @conversation = Conversation.new(params[:conversation])
    if person_ids.present? && @conversation.save
      Postzord::Dispatcher.build(current_user, @conversation).post
      @response[:success] = true
      @response[:message] = I18n.t('conversations.create.sent')
      @response[:conversation_id] = @conversation.id
    else
      @response[:success] = false
      @response[:message] = I18n.t('conversations.create.fail')
      if person_ids.blank?
        @response[:message] = I18n.t('conversations.create.no_follower')
      end
    end
    respond_to do |format|
      format.js
    end
  end

  def show
    if @conversation = Conversation.joins(:conversation_visibilities).where(:id => params[:id],
                                                                            :conversation_visibilities => {:person_id => current_user.person_id}).first

      @first_unread_message_id = @conversation.first_unread_message(current_user).try(:id)
      if @visibility = ConversationVisibility.where(:conversation_id => params[:id], :person_id => current_user.person.id).first
        @visibility.unread = 0
        @visibility.save
      end

      respond_to do |format|
        format.html { redirect_to conversations_path(:conversation_id => @conversation.id) }
        format.js
        format.json { render :json => @conversation, :status => 200 }
      end
    else
      redirect_to conversations_path
    end
  end

  def new
    all_followers_and_ids = Follower.connection.select_rows(
      current_user.followers.where(:sharing => true).joins(:person => :profile).
        select("followers.id, profiles.first_name, profiles.last_name, people.lygneo_handle").to_sql
    ).map{|r| {:value => r[0], :name => Person.name_from_attrs(r[1], r[2], r[3]).gsub(/(")/, "'")} }

    @follower_ids = ""

    @followers_json = all_followers_and_ids.to_json
    if params[:follower_id]
      @follower_ids = current_user.followers.find(params[:follower_id]).id
    elsif params[:group_id]
      @follower_ids = current_user.groups.find(params[:group_id]).followers.map{|c| c.id}.join(',')
    end
    if session[:mobile_view] == true && request.format.html?
    render :layout => true
    elsif
    render :layout => false
    end
  end
end
