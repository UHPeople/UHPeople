class PhotosController < ApplicationController
  before_action :require_login
  before_action :set_photo, only: [:show]

  def show
  end

  def create
    @photo = Photo.create(user_id: current_user.id, image_text: params[:image_text], image: params[:image])
    respond_to do |format|
      if @photo.save
        format.html { redirect_to current_user, notice: 'Photo was successfully added.' }
      else
        format.html { redirect_to current_user, notice: 'An error occured while saving photo.' }
      end
    end
  end

  private

  def set_photo
    @photo = Photo.find(params[:id])
  end

end
