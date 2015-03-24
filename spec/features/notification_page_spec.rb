require 'rails_helper'

RSpec.describe 'Notifications page' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    Notification.create(notification_type:1, user:user, tricker_user:user, tricker_hashtag:hashtag)
    visit "/login/#{user.id}"
  end

  it 'has notification page' do
    visit "/notifications"
    expect(page).to have_content 'Your notifications'
  end

  it 'has notification' do
    visit "/notifications"
    expect(page).to have_content 'asd asd has invited you to join avantouinti!'
  end  

  it 'has notification disappeard when clicked', js: true do
    visit "/notifications"
    find('.close',:visible => true).click
    expect(page).to have_content "You don't have any new notifications."
  end

  it 'has count of unread notification in nav bar' do
    visit "/notifications"
    expect(page).to have_content('1')
  end  

  it 'has count of unread notification in nav bar disappears if none', js: true do
    visit "/notifications"
    find('.close',:visible => true).click
    expect(page).not_to have_content('1')
  end
end

