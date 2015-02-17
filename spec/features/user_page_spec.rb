require 'spec_helper'

describe "Profile page" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
    visit "/hashtags/#{hashtag.id}"
    click_link 'Join'

    visit "/users/#{user.id}"
  end

  it "has name" do
    expect(page).to have_content 'asd asd'
  end

  it "has email" do
  	expect(page).to have_content 'asd@asd.fi'
  end

  it "has campus" do
  	expect(page).to have_content 'Viikki'
  end

  it "has unit" do
  	expect(page).to have_content 'Maametsis'
  end

  it "has about" do
  	expect(page).to have_content 'abouttest!!212'
  end

  it "has hashtags" do
  	expect(page).to have_content '#avantouinti'
  end
end