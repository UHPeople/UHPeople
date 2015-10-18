require 'rails_helper'

RSpec.describe 'Notifications page' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    Notification.create(notification_type: 1, user: user, tricker_user: user, tricker_hashtag: hashtag)
    visit "/login/#{user.id}"
  end

  it 'has notification page' do
    visit '/notifications'
    expect(page).to have_content 'Your notifications'
  end

  it 'has notification' do
    visit '/notifications'
    expect(page).to have_content 'asd asd has invited you to join #avantouinti'
  end

  it 'resets unread notification count', js: true do
    visit '/feed'
    expect(page).to have_content('1')

    visit '/notifications'

    visit '/feed'
    expect(page).to_not have_content('1')
  end

  describe 'actions' do
    it 'joins' do
      visit '/notifications'
      first('.mdl-card__menu > a').click
      expect(page.current_path).to eq "/hashtags/#{hashtag.tag}"
    end

    it 'takes to message', js: true do
      visit "/login/#{user.id}"
      visit hashtag_path(hashtag.tag)
      click_link 'add'

      message = FactoryGirl.create(:message, user: user, hashtag: hashtag, created_at: Time.now.utc)

      Notification.create(notification_type: 3, user: user, tricker_user: user,
                          tricker_hashtag: hashtag, message: message)

      visit '/notifications'
      first('.mdl-card__menu > a').click
      expect(page.current_path).to eq "/hashtags/#{hashtag.tag}"
      expect(URI.parse(page.current_url).fragment).to eq "#{message.id}"
    end
  end
end
