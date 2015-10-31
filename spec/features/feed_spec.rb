require 'rails_helper'

def create_and_visit
  Message.create user: user, hashtag: hashtag, content: 'Asdasd'
  visit '/feed'
end

RSpec.describe 'Feed page' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
    visit "/hashtags/#{hashtag.tag}"
    click_link 'add'
  end

  context 'feed tab', js: true do
    before :each do
      visit '/feed'
      click_link 'Feed'

      message = Message.create user: user, hashtag: hashtag, content: 'Asdasd', created_at: Time.now.utc
      page.execute_script("add_feed_message(#{JSON.generate(message.serialize)})")
    end

    it 'has messages in feed' do
      expect(page).to have_content 'Asdasd'
    end

    it 'has messages in feed in order' do
      message2 = Message.create user: user, hashtag: hashtag, content: 'Asdasd2', created_at: Time.now.utc
      page.execute_script("add_feed_message(#{JSON.generate(message2.serialize)})")

      expect(find('.feed-chat-box:nth-of-type(1)')).to have_content 'Asdasd2'
      expect(find('.feed-chat-box:nth-of-type(2)')).to have_content 'Asdasd'
    end

    it 'redirects hashtag box link to right hashtag when tag opened' do
      first(:link, 'avantouinti').click
      expect(page).to have_content 'avantouinti'
    end

    it 'doesn\'t have interests title if no hashtags' do
      visit "/hashtags/#{hashtag.tag}"
      first('.leave-button').click
      visit '/feed'

      expect(page).not_to have_content 'Interests'
    end

    it 'redirects to favourites tab when changing favourites', js: true do
      find('.interest-list-star a.like-this').click

      expect(URI.parse(page.current_url).fragment).to eq 'favourites'
    end

    it 'has thumbnails' do
      expect(first('#feed .img-circle')).to have_content ''
    end
  end

  context 'Interests list' do
    before :each do
      create_and_visit
    end

    it 'has unread count when visiting feed', js: true do
      visit "/users/#{user.id}"
      FactoryGirl.create(:message, user: user, hashtag: hashtag)
      hashtag.update_attribute(:updated_at, Time.now.utc)

      visit '/feed'
      expect(first('span.unread')).to have_content ''
    end
  end

  context 'favourites tab', js: true do
    before :each do
      visit '/feed'
      find('.interest-list-star a.like-this').click
      click_link 'Favourites'

      message = Message.create user: user, hashtag: hashtag, content: 'Asdasd', created_at: Time.now.utc
      page.execute_script("add_favourites_message(#{JSON.generate(message.serialize)})")
    end

    it 'has the right content when favourites exist' do
      expect(find('.favourites-chat-box:nth-of-type(1)')).to have_content 'Asdasd'
    end

    it 'is empty when favourite removed' do
      find('.interest-list-star a.like-this').click
      click_link 'Favourites'
      expect(page).to have_content 'You have no favourites selected. Star some interests to see something here!'
    end
  end

  it 'has tagcloud', js: true do
    Rails.cache.clear

    create_and_visit
    expect(find('span#tag_cloud_word_0')).to have_content 'avantouinti'
  end

  it 'has tagcloud with hottest tag biggest', js: true do
    Rails.cache.clear

    hashtag3 = Hashtag.create tag: 'cloudtag2'
    user.hashtags << hashtag3
    user.save
    Message.create user: user, hashtag: hashtag3, content: 'Asdasd3'
    Message.create user: user, hashtag: hashtag3, content: 'Asdasd4'
    Message.create user: user, hashtag: hashtag3, content: 'Asdasd5'

    visit '/feed'
    expect(find('span.w10')).to have_content 'cloudtag2'
  end

  context 'tab' do
    it 'is stored', js: true do
      create_and_visit

      click_link 'Favourites'
      visit '/feed'
      expect(user.tab).to eq 0

      click_link 'Feed'
      visit '/feed'
      # expect(user.tab).to eq 1
    end
  end
end
