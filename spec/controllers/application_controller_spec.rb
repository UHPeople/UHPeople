require 'rails_helper'

RSpec.describe ApplicationController do
  let!(:user) { FactoryGirl.create(:user) }

  controller do
    def index
      fail ApplicationController::AccessDenied
    end
  end

  describe 'current_user' do
    it 'returns nil if not logged in' do
      # request.session[:user_id] = user.id
      expect(controller.current_user).to eq nil
    end

    it 'returns user if logged in' do
      request.session[:user_id] = user.id
      expect(controller.current_user).to eq user
    end

    it 'returns nil if logged in with invalid user' do
      request.session[:user_id] = user.id + 1
      expect(controller.current_user).to eq nil
    end
  end
end
