require 'rails_helper'

RSpec.describe User do
  context 'edit page' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:hashtag) { FactoryGirl.create(:hashtag) }

    before :each do
      visit "/login/#{user.id}"
    end

    it 'after editing users unit and about, shows right information on user page' do
      visit edit_user_path(user)

      fill_in('about', with: 'Hauska tyyppi.')
      click_button('Update')

      expect(page).to have_content 'Hauska tyyppi.'
    end

    it 'is not shown with not logged in user' do
      user2 = described_class.create username: 'asd', name: 'asd', campus: 'asd'
      visit edit_user_path(user2)
      expect(current_path).to eq feed_index_path
    end
  end
end
