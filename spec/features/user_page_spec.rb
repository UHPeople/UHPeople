require 'spec_helper'

describe "Profile page" do
  let(:user) { FactoryGirl.create(:user) }

  it "has name" do
    visit "/users/#{user.id}"

    expect(page).to have_content 'asd asd'
  end

  it "has email" do
  	visit "/users/#{user.id}"

  	expect(page).to have_content 'asd@asd.fi'
  end

  it "has campus" do
  	visit "/users/#{user.id}"

  	expect(page).to have_content 'Viikki'
  end

  it "has unit" do
  	visit "/users/#{user.id}"

  	expect(page).to have_content 'Maametsis'
  end

  it "has about" do
  	visit "/users/#{user.id}"

  	expect(page).to have_content 'abouttest!!212'
  end

  it "has hashtags" do
  	user.hashtags << FactoryGirl.create(:hashtag)

  	visit "/users/#{user.id}"

  	expect(page).to have_content '#avantouinti'
  end
end