require 'rails_helper'

RSpec.describe User do
  context 'edit page' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:hashtag) { FactoryGirl.create(:hashtag) }

    before :each do
      visit "/login/#{user.id}"
    end

    it 'after editing users name and about, shows right information on user page' do
      visit edit_user_path(user)

      fill_in('user_name', with: 'Vaihdettu Nimi')
      fill_in('user_about', with: 'Hauska tyyppi.')

      click_button('Update')

      expect(page).to have_content 'Vaihdettu Nimi'
      expect(page).to have_content 'Hauska tyyppi.'
    end

    it 'shows errors on invalid changes' do
      visit edit_user_path(user)

      fill_in('user_name', with: '')
      click_button('Update')

      expect(page).to have_content '1 error prohibited changes from being saved:'
    end
  end
end
