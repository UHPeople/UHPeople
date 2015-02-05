require 'spec_helper'

describe "Hashtag page" do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
  end

  it "has edit topic button" do
    go_to_hashtag_join

    expect(page).to have_content 'Click to edit topic!'
  end

  it "has updated topic" do
    go_to_hashtag_join
    fill_in 'topic', with: 'This is the topic!'
    click_button 'Update topic!'

    expect(page).to have_content 'This is the topic!'
  end

  it "has working leave button" do
    go_to_hashtag_join
    click_link 'Leave'

    expect(page).to have_content 'Join'
  end

  def go_to_hashtag_join
    visit "/hashtags/#{hashtag.id}"
    click_link 'Join'
  end

end