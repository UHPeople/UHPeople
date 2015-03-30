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

      fill_in('user_title', with: 'Ope')
      fill_in('user_about', with: 'Hauska tyyppi.')

      click_button('Update')

      expect(page).to have_content 'Ope'
      expect(page).to have_content 'Hauska tyyppi.'
    end

    it 'is not shown with not logged in user' do
      user2 = User.create username: 'asd', name: 'asd'
      visit edit_user_path(user2)
      expect(current_path).to eq '/feed'
    end

    it 'prevents changing name on first login' do
      visit edit_user_path(user)

      expect(page).not_to have_field('name')
    end

  end
end
