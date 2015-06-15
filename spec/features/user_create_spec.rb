require 'rails_helper'

RSpec.describe User do
  context 'new user page' do
    it 'adds hashtags for campus on create' do
      visit new_user_path

      fill_in('user_name', with: 'Ope')

      page.select 'Kumpula Campus', from: 'user_campus'

      click_button('Update')

      expect(Hashtag.count).to eq(1)

      expect(described_class.first.hashtags.first.tag).to eq('Kumpula_Campus')
    end

    it 'adds correct hashtag to user if tag already exists' do
      FactoryGirl.create(:hashtag, tag: 'Kumpula_Campus')
      visit new_user_path

      fill_in('user_name', with: 'Ope')

      page.select 'Kumpula Campus', from: 'user_campus'

      click_button('Update')

      expect(Hashtag.count).to eq(1)

      expect(described_class.first.hashtags.first.tag).to eq('Kumpula_Campus')
    end
  end
end
