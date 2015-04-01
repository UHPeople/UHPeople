class PhotosController < ApplicationController
  before_action :require_login
  before_action :set_photo, only: [:show, :destroy, :update]

  def show
  end

  def update
    unless @photo.update(image_text: params[:image_text])
      redirect_to :back, notice: 'Something went wrong!'
      return
    end
    redirect_to :back, notice: 'Title was successfully updated.'
  end

  def destroy
    if @photo.id == current_user.profilePicture
      u = current_user
      u.profilePicture = nil
      u.save
    end
    current_user.photos.destroy(@photo)
    redirect_to current_user, notice: 'Photo was successfully deleted.'
  end

  def create
    @maxphotos = 5
    @photo = Photo.create(user_id: current_user.id, image_text: params[:image_text], image: params[:image])
    respond_to do |format|
      if current_user.photos.count < @maxphotos
        if @photo.save
          format.html { redirect_to current_user, notice: 'Photo was successfully added.' }
        else
          format.html { redirect_to current_user, notice: 'An unknown error occured while saving your photo. Please try again' }
        end
      else
        format.html { redirect_to current_user, notice: "You have added the maximum amount of #{@maxphotos} photos, you have to remove some to add new ones."}
      end
    end
  end

  private

  def set_photo
    @photo = Photo.find(params[:id])
  end

end
