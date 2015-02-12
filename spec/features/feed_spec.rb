require 'spec_helper'

describe "Feed page" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
    visit "/hashtags/#{hashtag.id}"
    click_link 'Join'
  end

  it "has messages" do
    message = Message.create user: user, hashtag: hashtag, content: 'Asdasd'
    visit '/feed'
    expect(page).to have_content 'Asdasd'
  end
end