require 'spec_helper'

describe "Hashtag page chat" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    user.hashtags << hashtag
    visit "/login/#{user.id}"
  end

  it "has send button" do
    visit "/hashtags/#{hashtag.id}"

    expect(page).to have_content 'Send'
  end

  it "has related messages" do
    FactoryGirl.create(:message, user: user, hashtag: hashtag)
    visit "/hashtags/#{hashtag.id}"

    expect(page).to have_content 'Hello World!'
  end

  it "can send a message", :js => true do
    visit "/hashtags/#{hashtag.id}"

    fill_in('input-text', with:'Hello world!')
    click_button('Send')
    expect(page).to have_content('Hello world!')
  end
end