require 'spec_helper'

describe "Hashtag page chat" do
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  it "has send button" do
    visit "/hashtags/#{hashtag.id}"

    expect(page).to have_content('Send')
  end

  
  #it "can be written a message", :js => true do
  #  visit "/hashtags/#{hashtag.id}"

  #  fill_in('input-text', with:'Hello world!')
  #  click_button('Send')

  #  fill_in('input-text', with:'Hello world!')
  #  click_button('Send')

  #  expect(page).to have_content('Hello world!')
  #end
end