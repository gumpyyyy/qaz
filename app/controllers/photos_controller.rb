#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

class PhotosController < ApplicationController
  before_filter :authenticate_user!, :except => :show

  respond_to :html, :json

  def show
    @photo = Photo.find(params[:id])
  end

  def index
    @post_type = :photos
    @person = Person.find_by_guid(params[:person_id])

    if @person
      @follower = current_user.follower_for(@person)

      if @follower
        @followers_of_follower = @follower.followers
        @followers_of_follower_count = @follower.followers.count
      else
        @follower = Follower.new
      end

      @posts = current_user.photos_from(@person)

      respond_to do |format|
        format.all { render 'people/show' }
        format.json{ render_for_api :backbone, :json => @posts, :root => :photos }
      end

    else
      flash[:error] = I18n.t 'people.show.does_not_exist'
      redirect_to people_path
    end
  end

  def create
    rescuing_photo_errors do
      if remotipart_submitted?
        @photo = current_user.build_post(:photo, params[:photo])
        if @photo.save
          respond_to do |format|
            format.json { render :json => {"success" => true, "data" => @photo.as_api_response(:backbone)} }
          end
        else
          respond_with @photo, :location => photos_path, :error => message
        end
      else
        legacy_create
      end
    end
  end

  def make_profile_photo
    author_id = current_user.person_id
    @photo = Photo.where(:id => params[:photo_id], :author_id => author_id).first

    if @photo
      profile_hash = {:image_url        => @photo.url(:thumb_large),
                      :image_url_medium => @photo.url(:thumb_medium),
                      :image_url_small  => @photo.url(:thumb_small)}

      if current_user.update_profile(profile_hash)
        respond_to do |format|
          format.js{ render :json => { :photo_id  => @photo.id,
                                       :image_url => @photo.url(:thumb_large),
                                       :image_url_medium => @photo.url(:thumb_medium),
                                       :image_url_small  => @photo.url(:thumb_small),
                                       :author_id => author_id},
                            :status => 201}
        end
      else
        render :nothing => true, :status => 422
      end
    else
      render :nothing => true, :status => 422
    end
  end

  def destroy
    photo = current_user.photos.where(:id => params[:id]).first

    if photo
      current_user.retract(photo)

      respond_to do |format|
        format.json{ render :nothing => true, :status => 204 }
        format.html do
          flash[:notice] = I18n.t 'photos.destroy.notice'
          if StatusMessage.find_by_guid(photo.status_message_guid)
              respond_with photo, :location => post_path(photo.status_message)
          else
            respond_with photo, :location => person_photos_path(current_user.person)
          end
        end
      end
    else
      respond_with photo, :location => person_photos_path(current_user.person)
    end
  end

  def edit
    if @photo = current_user.photos.where(:id => params[:id]).first
      respond_with @photo
    else
      redirect_to person_photos_path(current_user.person)
    end
  end

  def update
    photo = current_user.photos.where(:id => params[:id]).first
    if photo
      if current_user.update_post( photo, params[:photo] )
        flash.now[:notice] = I18n.t 'photos.update.notice'
        respond_to do |format|
          format.js{ render :json => photo, :status => 200 }
        end
      else
        flash.now[:error] = I18n.t 'photos.update.error'
        respond_to do |format|
          format.html{ redirect_to [:edit, photo] }
          format.js{ render :status => 403 }
        end
      end
    else
      redirect_to person_photos_path(current_user.person)
    end
  end

  private

  def file_handler(params)
    # For XHR file uploads, request.params[:qqfile] will be the path to the temporary file
    # For regular form uploads (such as those made by Opera), request.params[:qqfile] will be an UploadedFile which can be returned unaltered.
    if not request.params[:qqfile].is_a?(String)
      params[:qqfile]
    else
      ######################## dealing with local files #############
      # get file name
      file_name = params[:qqfile]
      # get file content type
      att_content_type = (request.content_type.to_s == "") ? "application/octet-stream" : request.content_type.to_s
      # create tempora##l file
      file = Tempfile.new(file_name, {:encoding =>  'BINARY'})
      # put data into this file from raw post request
      file.print request.raw_post.force_encoding('BINARY')

      # create several required methods for this temporal file
      Tempfile.send(:define_method, "content_type") {return att_content_type}
      Tempfile.send(:define_method, "original_filename") {return file_name}
      file
    end
  end

  def legacy_create
    if params[:photo][:group_ids] == "all"
      params[:photo][:group_ids] = current_user.groups.collect { |x| x.id }
    elsif params[:photo][:group_ids].is_a?(Hash)
      params[:photo][:group_ids] = params[:photo][:group_ids].values
    end

    params[:photo][:user_file] = file_handler(params)

    @photo = current_user.build_post(:photo, params[:photo])

    if @photo.save
      groups = current_user.groups_from_ids(params[:photo][:group_ids])

      unless @photo.pending
        current_user.add_to_streams(@photo, groups)
        current_user.dispatch_post(@photo, :to => params[:photo][:group_ids])
      end

      if params[:photo][:set_profile_photo]
        profile_params = {:image_url => @photo.url(:thumb_large),
                          :image_url_medium => @photo.url(:thumb_medium),
                          :image_url_small => @photo.url(:thumb_small)}
        current_user.update_profile(profile_params)
      end

      respond_to do |format|
        format.json{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
        format.html{ render(:layout => false , :json => {"success" => true, "data" => @photo}.to_json )}
      end
    else
      respond_with @photo, :location => photos_path, :error => message
    end
  end

  def rescuing_photo_errors
    begin
      yield
    rescue TypeError
      message = I18n.t 'photos.create.type_error'
      respond_with @photo, :location => photos_path, :error => message

    rescue CarrierWave::IntegrityError
      message = I18n.t 'photos.create.integrity_error'
      respond_with @photo, :location => photos_path, :error => message

    rescue RuntimeError => e
      message = I18n.t 'photos.create.runtime_error'
      respond_with @photo, :location => photos_path, :error => message
      raise e
    end
  end
end
