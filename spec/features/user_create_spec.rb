require 'rails_helper'

RSpec.describe User do
  context 'new user page' do

    it 'adds hashtags for unit and campus on create' do
      visit new_user_path

      fill_in('user_name', with: 'Ope')

      page.select 'Kumpula Campus', from: 'user_campus'

      page.select 'Faculty of Arts', from: 'user_unit'

      click_button('Update')

      expect(Hashtag.count).to eq(2)

      expect(User.first.hashtags.first.tag).to eq('Kumpula_Campus')
      expect(User.first.hashtags.last.tag).to eq('Faculty_of_Arts')
    end

    it 'adds correct hashtag to user if tag already exists' do
      FactoryGirl.create(:hashtag, tag: 'Kumpula_Campus')
      visit new_user_path

      fill_in('user_name', with: 'Ope')

      page.select 'Kumpula Campus', from: 'user_campus'

      page.select 'Faculty of Arts', from: 'user_unit'

      click_button('Update')

      expect(Hashtag.count).to eq(2)

      expect(User.first.hashtags.first.tag).to eq('Kumpula_Campus')
      expect(User.first.hashtags.last.tag).to eq('Faculty_of_Arts')
    end

  end
end
