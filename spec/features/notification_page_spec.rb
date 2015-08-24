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
end
