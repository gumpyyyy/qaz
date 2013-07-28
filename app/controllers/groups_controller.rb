#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class GroupsController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html,
             :js,
             :json

  def create
    @group = current_user.groups.build(params[:group])
    grouping_person_id = params[:group][:person_id]

    if @group.save
      flash[:notice] = I18n.t('groups.create.success', :name => @group.name)

      if current_user.getting_started || request.referer.include?("followers")
        redirect_to :back
      elsif grouping_person_id.present?
        connect_person_to_group(grouping_person_id)
      else
        redirect_to followers_path(:a_id => @group.id)
      end
    else
      respond_to do |format|
        format.js { render :text => I18n.t('groups.create.failure'), :status => 422 }
        format.html do
          flash[:error] = I18n.t('groups.create.failure')
          redirect_to :back
        end
      end
    end
  end

  def new
    @group = Group.new
    @person_id = params[:person_id]
    @remote = params[:remote] == "true"
    respond_to do |format|
      format.html { render :layout => false }
    end
  end

  def destroy
    @group = current_user.groups.where(:id => params[:id]).first

    begin
      @group.destroy
      flash[:notice] = I18n.t 'groups.destroy.success', :name => @group.name
    rescue ActiveRecord::StatementInvalid => e
      flash[:error] = I18n.t 'groups.destroy.failure', :name => @group.name
    end
    if request.referer.include?('followers')
      redirect_to followers_path
    else
      redirect_to groups_path
    end
  end

  def show
    if @group = current_user.groups.where(:id => params[:id]).first
      redirect_to groups_path('a_ids[]' => @group.id)
    else
      redirect_to groups_path
    end
  end

  def edit
    @group = current_user.groups.where(:id => params[:id]).includes(:followers => {:person => :profile}).first

    @followers_in_group = @group.followers.includes(:group_pledges, :person => :profile).all.sort! { |x, y| x.person.name <=> y.person.name }
    c = Follower.arel_table
    if @followers_in_group.empty?
      @followers_not_in_group = current_user.followers.includes(:group_pledges, :person => :profile).all.sort! { |x, y| x.person.name <=> y.person.name }
    else
      @followers_not_in_group = current_user.followers.where(c[:id].not_in(@followers_in_group.map(&:id))).includes(:group_pledges, :person => :profile).all.sort! { |x, y| x.person.name <=> y.person.name }
    end

    @followers = @followers_in_group + @followers_not_in_group

    unless @group
      render :file => Rails.root.join('public', '404.html').to_s, :layout => false, :status => 404
    else
      @group_ids = [@group.id]
      @group_followers_count = @group.followers.size
      render :layout => false
    end
  end

  def update
    @group = current_user.groups.where(:id => params[:id]).first

    if @group.update_attributes!(params[:group])
      flash[:notice] = I18n.t 'groups.update.success', :name => @group.name
    else
      flash[:error] = I18n.t 'groups.update.failure', :name => @group.name
    end
    render :json => { :id => @group.id, :name => @group.name }
  end

  def toggle_follower_visibility
    @group = current_user.groups.where(:id => params[:group_id]).first

    if @group.followers_visible?
      @group.followers_visible = false
    else
      @group.followers_visible = true
    end
    @group.save
  end

  private

  def connect_person_to_group(grouping_person_id)
    @person = Person.find(grouping_person_id)
    if @follower = current_user.follower_for(@person)
      @follower.groups << @group
    else
      @follower = current_user.share_with(@person, @group)
    end
  end
end
