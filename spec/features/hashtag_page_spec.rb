require 'rails_helper'

RSpec.describe Hashtag do
  context 'page' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:hashtag) { FactoryGirl.create(:hashtag) }

    before :each do
      visit "/login/#{user.id}"
      visit "/hashtags/#{hashtag.tag}"
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

    it 'has invitation box' do
      fill_in 'user', with: user.name
      click_button 'Invite'

      expect(find('.notif-count')).to have_content '1'
    end
  end
end
