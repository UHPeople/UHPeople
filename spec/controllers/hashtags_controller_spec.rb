require 'rails_helper'

RSpec.describe HashtagsController do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    request.session[:user_id] = user.id
  end

  describe 'POST add_multiple' do
    it 'adds existing hashtag' do
      post :add_multiple, hashtags: hashtag.tag
      user.reload

      expect(user.hashtags.count).to eq 1
      expect(user.hashtags.first).to eq hashtag
    end

    it 'creates new hashtag' do
      post :add_multiple, hashtags: 'asdsasdasd'
      user.reload

      expect(user.hashtags.count).to eq 1
    end

    it 'adds and creates multiple hashtags' do
      post :add_multiple, hashtags: 'asdsasdasd,' + hashtag.tag
      user.reload

      expect(user.hashtags.count).to eq 2
    end

    it 'removes all hashtags on empty' do
      post :add_multiple, hashtags: ''
      user.reload

      expect(user.hashtags).to eq []
    end
  end

  describe 'POST create' do
    it 'creates new hashtag' do
      post :create, tag: 'superuniikki200'
      user.reload

      expect(user.hashtags.count).to eq 1
      expect(user.hashtags.first.tag).to eq 'superuniikki200'
    end

    it 'adds user existing hashtag' do
      post :create, tag: hashtag.tag
      user.reload

      expect(user.hashtags.count).to eq 1
      expect(user.hashtags.first).to eq hashtag
    end
  end
end
