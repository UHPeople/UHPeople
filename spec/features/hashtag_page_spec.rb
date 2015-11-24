require 'rails_helper'

RSpec.describe Hashtag do
  context 'page' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:hashtag) { FactoryGirl.create(:hashtag) }

    before :each do
      visit "/login/#{user.id}"
      visit "/hashtags/#{hashtag.tag}"
      click_link 'add'
    end

    it 'has add topic button' do
      expect(page).to have_content 'Add topic'
    end

    it 'has edit channel button' do
      expect(page).to have_content 'Edit channel'
    end

    it 'has updated topic', js: true do
      # WebSocket backend won't answer
      # find('.edit-modal__open').click
      # fill_in 'topic', with: 'This is the topic!'
      # click_button 'Update'

      json = {
        hashtag: hashtag.id,
        topic: 'This is the topic!',
        user: '',
        cover: '',
        timestamp: ''
      }

      page.execute_script("change_topic(#{JSON.generate(json)})")
      expect(page).to have_content 'This is the topic!'
    end

    it 'has working leave button when not the only member' do
      visit '/logout'
      user2 = FactoryGirl.create(:user, username: 'uusityyppi')
      visit "/login/#{user2.id}"
      visit "/hashtags/#{hashtag.tag}"
      click_link 'add'
      first('.leave-button').click

      expect(page).to have_content 'add'
    end

    it 'is deleted when last member leaves' do
      tag = hashtag.tag
      first('.leave-button').click
      expect(page.current_path).to eq '/feed'

      visit "/search?search=%23#{tag}"
      expect(page).to have_no_content "Search results for channels: ##{tag}"
    end

    context 'invitation box', js: true do
      it 'sends invitation to non-member user' do
        user2 = User.create name: 'asd', username: 'asdasd', campus: 'asd'
        first('a.invite-modal__open').click
        fill_in 'user', with: user2.name
        find('.invite-button').click

        visit "/login/#{user2.id}"

        expect(page).to have_selector('.notif-link .mdl-badge[data-badge="1"]')
      end

      it 'doesn\'t send invitation to member' do
        first('a.invite-modal__open').click
        fill_in 'user', with: user.name
        find('.invite-button').click

        expect(page).to have_selector('.notif-link .mdl-badge[data-badge="0"]')
      end
    end
  end
end
