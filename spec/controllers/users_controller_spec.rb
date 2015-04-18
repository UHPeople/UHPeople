require 'rails_helper'

RSpec.describe UsersController do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:photo) { FactoryGirl.create(:photo, user_id: user.id) }

  describe 'POST set_profile_picture' do
    before :each do
      request.session[:user_id] = user.id
    end

    it 'sets picture' do
      post :set_profile_picture, pic_id: photo.id
      user.reload

      expect(user.profilePicture).to eq photo.id
    end

    it 'fails on invalid picture' do
      post :set_profile_picture, pic_id: photo.id + 1
      expect(user.profilePicture).to eq nil
    end
  end

  describe 'GET shibboleth_callback' do
    it 'logs existing user in' do
      request.env['omniauth.auth'] = {
        'info' => { 'name' => '', 'mail' => '' },
        'uid' => user.username
      }

      get :shibboleth_callback

      expect(request.session[:user_id]).to eq user.id
    end
  end

  #describe 'POST create' do
  #  it 'adds photo to user' do
  #    post :create, user: { username: 'asd', name: 'asdasd' }, image: photo
  #    user = User.last
  #    expect(user.profilePicture).to eq photo.id
  #  end
  #end
end
