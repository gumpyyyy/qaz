#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

class GroupPledgesController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json

  def destroy
    group = current_user.groups.joins(:group_pledges).where(:group_pledges=>{:id=>params[:id]}).first
    follower = current_user.followers.joins(:group_pledges).where(:group_pledges=>{:id=>params[:id]}).first

    raise ActiveRecord::RecordNotFound unless group.present? && follower.present?

    raise Lygneo::NotMine unless current_user.mine?(group) &&
                                   current_user.mine?(follower)

    pledge = follower.group_pledges.where(:group_id => group.id).first

    raise ActiveRecord::RecordNotFound unless pledge.present?

    # do it!
    success = pledge.destroy

    # set the flash message
    if success
      flash.now[:notice] = I18n.t 'group_pledges.destroy.success'
    else
      flash.now[:error] = I18n.t 'group_pledges.destroy.failure'
    end

    respond_with do |format|
      format.json do
        if success
          render :json => {
            :person_id  => follower.person_id,
            :group_ids => follower.groups.map{|a| a.id}
          }
        else
          render :text => pledge.errors.full_messages, :status => 403
        end
      end

      format.all { redirect_to :back }
    end
  end

  def create
    @person = Person.find(params[:person_id])
    @group = current_user.groups.where(:id => params[:group_id]).first

    @follower = current_user.share_with(@person, @group)

    if @follower.present?
      flash.now[:notice] =  I18n.t('groups.add_to_group.success')
      respond_with do |format|
        format.json do
          render :json => GroupPledge.where(:follower_id => @follower.id, :group_id => @group.id).first.to_json
        end

        format.all { redirect_to :back }
      end
    else
      flash.now[:error] = I18n.t('followers.create.failure')
      render :nothing => true, :status => 409
    end
  end

  rescue_from ActiveRecord::StatementInvalid do
    render :text => "Duplicate record rejected.", :status => 400
  end

  rescue_from ActiveRecord::RecordNotFound do
    render :text => I18n.t('group_pledges.destroy.no_pledge'), :status => 404
  end

  rescue_from Lygneo::NotMine do
    render :text => "You are not allowed to do that.", :status => 403
  end

end
