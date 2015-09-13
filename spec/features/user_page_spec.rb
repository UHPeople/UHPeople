require 'rails_helper'

RSpec.describe User do
  context 'Profile page' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:hashtag) { FactoryGirl.create(:hashtag) }

    before :each do
      visit "/login/#{user.id}"
      visit "/hashtags/#{hashtag.tag}"
      click_link 'Join'

      visit "/users/#{user.id}"
    end

    it 'has name' do
      expect(page).to have_content 'asd asd'
    end

    it 'has email' do
      expect(page).to have_content 'asd@asd.fi'
    end

    it 'has campus' do
      expect(page).to have_content 'Viikki'
    end

    it 'has about' do
      expect(page).to have_content 'abouttest!!212'
    end

    it 'has hashtags' do
      expect(page).to have_content '#avantouinti'
    end

    it "doesn't have interests title if no hashtags" do
      visit "/hashtags/#{hashtag.tag}"
      first('.leave-button').click
      visit "/users/#{user.id}"

      expect(page).not_to have_content 'Interests'
    end

    it 'has button and form for adding photos' do
      click_link 'Add photo'
      expect(page).to have_content 'Photo title'
    end

    it 'can add photos to album' do
      click_link 'Add photo'
      expect(page).to have_content 'Photo title'
    end

    it 'doesn´t have active channels if should not' do
      visit "/users/#{user.id}"
      expect(page).not_to have_content 'More active'
      expect(page).to have_content 'Less active'
    end

    it 'has active channels if has' do
      Message.create content: 'asd', hashtag_id: hashtag.id, user_id: user.id

      visit "/users/#{user.id}"
      expect(page).to have_content 'More active'
      expect(page).not_to have_content 'Less active'
    end

    it 'has in common button if same hashtag' do
      u2 = User.create name: 'asd asd', username: 'asd2', email: 'asd@asd.fi', campus: 'Viikki', about: 'abouttest!!212', first_time: false
      u2.hashtags << hashtag
      visit "/users/#{u2.id}"
      expect(page).to have_content 'You have 1'
    end

    it 'doesn´t have common button if on current_user page' do
      visit "/users/#{user.id}"
      expect(page).not_to have_content 'You have'
    end

    it 'doesn´t have common button if no common' do
      u2 = User.create name: 'asd asd', username: 'asd2', email: 'asd@asd.fi', campus: 'Viikki', about: 'abouttest!!212', first_time: false

      visit "/users/#{u2.id}"
      expect(page).not_to have_content 'You have'
    end
  end
end
