require 'rails_helper'

RSpec.describe Hashtag do
  context 'chat page' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:hashtag) { FactoryGirl.create(:hashtag) }

    before :each do
      user.hashtags << hashtag
      visit "/login/#{user.id}"
    end

    it 'has send button' do
      visit "/hashtags/#{hashtag.id}"

      expect(find('//form/div/span/input')).to have_content ''
    end

    context 'messages' do
      before :each do
        FactoryGirl.create(:message, user: user, hashtag: hashtag)
        visit "/hashtags/#{hashtag.id}"
      end

      it 'have content' do
        expect(page).to have_content 'Hello World!'
      end

      it 'have a thumbnail' do
        expect(find('.img-circle')).to have_content ''
      end
    end

    it 'can send a message', type: :feature, js: true do
      visit "/hashtags/#{hashtag.id}"

      fill_in('input-text', with: 'Hello world!')
      click_button('Send')
      expect(page).to have_content('Hello world!')
    end
  end
end
