require 'spec_helper'

describe "Search page" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
    visit "/hashtags/#{hashtag.id}"
    click_link 'Join'
  end

  it "creates hashtags" do
    visit "/search?search=asd"
    click_link 'asd'
    expect(page).to have_content '#asd'
  end
end