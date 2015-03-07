require 'rails_helper'

RSpec.describe 'Feed page' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
    visit "/hashtags/#{hashtag.id}"
    click_link 'Join'
  end

  it 'has messages in feed' do
    create_and_visit
    expect(page).to have_content 'Asdasd'
  end

  it 'has messages in feed in order' do
    Message.create user: user, hashtag: hashtag, content: 'Asdasd2'
    create_and_visit

    expect(find('div.feed_chat_box:first-child')).to have_content 'Asdasd'
  end

  it 'has messages in favourites' do
    create_and_visit
    click_link 'Favourites'
    expect(page).to have_content 'Asdasd'
  end

  it 'redirects hashtag box link to right hashtag when tag opened' do
    create_and_visit

    first('.panel-title').click_link 'avantouinti'
    expect(page).to have_content 'Asdasd'
    expect(page).to have_content 'Members'
    expect(page).to have_content 'asd asd'
  end

  it "doesn't have groups title if no hashtags" do
    visit "/hashtags/#{hashtag.id}"
    click_link 'Leave'
    visit '/feed'

    expect(page).not_to have_content 'Groups'
  end
end

def create_and_visit
  Message.create user: user, hashtag: hashtag, content: 'Asdasd'
  visit '/feed'
end
