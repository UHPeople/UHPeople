class PhotosController < ApplicationController
  before_action :require_login
  before_action :set_photo, only: [:update, :destroy, :show]

  def update
    unless @photo.update(image_text: params[:image_text])
      redirect_to :back, alert: 'Something went wrong!'
      return
    end

    redirect_to :back, notice: 'Title was successfully updated.'
  end

  def destroy
    current_user.update_attribute(:profilePicture, nil) if @photo.id == current_user.profilePicture
    current_user.photos.destroy @photo
    redirect_to current_user, notice: 'Photo was successfully deleted.'
  end

  def create
    photo = Photo.new(photo_params)

    if photo.save
      # redirect_to current_user, notice: 'Photo was successfully added.'
    else
      # redirect_to current_user, alert: 'An unknown error occured while saving your photo. Please try again.'
    end
  end

  def show
    render :show, layout: false
  end

  private

  def photo_params
    params.permit(:image, :image_text).merge(user_id: current_user.id)
  end

  def set_photo
    @photo = Photo.find(params[:id])
  end

end
