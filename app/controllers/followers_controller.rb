#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class FollowersController < ApplicationController
  before_filter :authenticate_user!

  def index
    respond_to do |format|

      # Used for normal requests to followers#index and subsequent infinite scroll calls
      format.html { set_up_followers }

      # Used by the mobile site
      format.mobile { set_up_followers }

      # Used to populate mentions in the publisher
      format.json {
        group_ids = params[:group_ids] || current_user.groups.map(&:id)
        @people = Person.all_from_groups(group_ids, current_user).for_json
        render :json => @people.to_json
      }
    end
  end

  def sharing
    @followers = current_user.followers.sharing.includes(:group_pledges)
    render :layout => false
  end

  def spotlight
    @spotlight = true
    @people = Person.popular
  end

  private

  def set_up_followers
    @followers = case params[:set]
      when "only_sharing"
        current_user.followers.only_sharing
      when "all"
        current_user.followers
      else
        if params[:a_id]
          @group = current_user.groups.find(params[:a_id])
          @group.followers
        else
          current_user.followers.receiving
        end
    end
    @followers = @followers.for_a_stream.paginate(:page => params[:page], :per_page => 25)
    @followers_size = @followers.length
  end
end
