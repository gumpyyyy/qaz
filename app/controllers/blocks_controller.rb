class BlocksController < ApplicationController
  before_filter :authenticate_user!

  respond_to :html, :json

  def create
    block = current_user.blocks.new(params[:block])

    if block.save
      disconnect_if_follower(block.person)
      notice = {:notice => t('blocks.create.success')}
    else
      notice = {:error => t('blocks.create.failure')}
    end

    respond_with do |format|
      format.html{ redirect_to :back, notice }
      format.json{ render :nothing => true, :status => 204 }
    end
  end

  def destroy
    if current_user.blocks.find(params[:id]).delete
      notice = {:notice => t('blocks.destroy.success')}
    else
      notice = {:error => t('blocks.destroy.failure')}
    end

    respond_with do |format|
      format.html{ redirect_to :back, notice }
      format.json{ render :nothing => true, :status => 204 }
    end
  end

  private

  def disconnect_if_follower(person)
    if follower = current_user.follower_for(person)
      current_user.disconnect(follower, :force => true)
    end
  end
end
