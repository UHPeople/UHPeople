class PhotosController < ApplicationController
  before_action :require_login
  before_action :set_photo, only: [:show]

  def show

  end

  def create
    @photo = Photo.create(photo_params)

    respond_to do |format|
      if @photo.save
        format.html { redirect_to current_user, notice: 'Photo was successfully added.' }
      else
        format.html { redirect_to current_user, notice: 'an error occured while saving photo.' }
      end
    end
  end

  private

  def photo_params
    params.require(:photo).permit(:user_id, :photo_text, :photo)
  end

  def set_photo
    @photo = Photo.find(params[:id])
  end

end
