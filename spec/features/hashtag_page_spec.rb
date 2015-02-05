require 'spec_helper'

describe "Hashtag page" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
  end

  it "has edit topic button" do
    visit "/hashtags/#{hashtag.id}"
    click_link('Join')

    expect(page).to have_content('Click to edit topic!')
  end

  it "has updated topic" do
    visit "/hashtags/#{hashtag.id}"
    click_link('Join')
    fill_in('topic', with:'This is the topic!')
    click_button('Update topic!')
    expect(page).to have_content('updated')
    expect(page).to have_content('This is the topic!')

  end

end