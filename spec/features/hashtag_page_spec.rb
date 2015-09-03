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

    it 'has edit channel button' do
      fill_in 'topic', with: 'This is the topic!'
      click_button 'Update'
      expect(page).to have_content 'Edit channel'
    end

    it 'has updated topic' do
      fill_in 'topic', with: 'This is the topic!'
      click_button 'Update'

      expect(page).to have_content 'This is the topic!'
    end

    it 'has working leave button when not the only member' do
      visit "/logout"
      user2 = FactoryGirl.create(:user, username: 'uusityyppi')
      visit "/login/#{user2.id}"
      visit "/hashtags/#{hashtag.tag}"
      click_link 'Join'
      first('.leave-button').click

      expect(page).to have_content 'Join'
    end

    it 'is deleted when last member leaves' do
      tag = hashtag.tag
      first('.leave-button').click
      expect(page.current_path).to eq "/feed"

      visit "/search?search=%23#{tag}"
      expect(page).to have_no_content "Search results for channels: ##{tag}"
    end

    context 'invitation box' do
      it 'doesn\'t send invitation to member' do
        first('//a[data-target="#invite"]').click
        fill_in 'user', with: user.name
        find('input[value="Invite"]').click
        expect(find('.notif-count')).to_not have_content '1'
      end

      it 'sends invitation to non-member user' do
        user2 = User.create name: 'asd', username: 'asdasd', campus: 'asd'
        first('//a[data-target="#invite"]').click
        fill_in 'user', with: user2.name
        find('input[value="Invite"]').click

        visit "/login/#{user2.id}"

        expect(find('.notif-count')).to have_content '1'
      end
    end
  end
end
