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

      fill_in('unit', with: 'Uusi Yksikkö')
      fill_in('user_about', with: 'Hauska tyyppi.')

      click_button('Update')

      expect(page).to have_content 'Uusi Yksikkö'
      expect(page).to have_content 'Hauska tyyppi.'
    end

  end
end
