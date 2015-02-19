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
    create_and_visit
    expect(page).to have_content 'Asdasd'
  end

  it "redirects hashtag box link to right hashtag when tag opened" do
    create_and_visit

    first('.panel-title').click_link 'avantouinti'
    expect(page).to have_content 'Asdasd'
    expect(page).to have_content 'Members'
    expect(page).to have_content 'asd asd'
  end
end

def create_and_visit
  message = Message.create user: user, hashtag: hashtag, content: 'Asdasd'
  visit '/feed'
end