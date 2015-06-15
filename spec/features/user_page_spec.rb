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
      click_link 'Leave'
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
  end
end
