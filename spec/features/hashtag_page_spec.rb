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

    context 'invitation box' do
      it 'doesn\'t send invitation to member' do
        find('button[data-target="#invite"]').click
        fill_in 'user', with: user.name
        find('input[value="Invite"]').click
        expect(find('.notif-count')).to_not have_content '1'
      end

      it 'sends invitation to non-member user' do
        user2 = User.create name: 'asd', username: 'asdasd', campus: 'asd', unit: 'asd'
        find('button[data-target="#invite"]').click
        fill_in 'user', with: user2.name
        find('input[value="Invite"]').click

        visit "/login/#{user2.id}"

        expect(find('.notif-count')).to have_content '1'
      end
    end
  end
end
