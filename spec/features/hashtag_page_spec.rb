require 'spec_helper'

describe 'Hashtag page' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
    visit "/hashtags/#{hashtag.id}"
    click_link 'Join'
  end

  it 'has add topic button' do
    expect(page).to have_content 'Add topic'
  end

  it 'has edit topic button' do
    fill_in 'topic', with: 'This is the topic!'
    click_button 'Update'
    expect(page).to have_content 'Edit topic'
  end

  it 'has updated topic' do
    fill_in 'topic', with: 'This is the topic!'
    click_button 'Update'

    expect(page).to have_content 'This is the topic!'
  end

  it 'has working leave button' do
    click_link 'Leave'

    expect(page).to have_content 'Join'
  end
end
