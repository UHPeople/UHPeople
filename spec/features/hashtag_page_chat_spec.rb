require 'rails_helper'

RSpec.describe Hashtag do
  context 'chat page' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:hashtag) { FactoryGirl.create(:hashtag) }

    before :each do
      visit "/login/#{user.id}"
      visit hashtag_path(hashtag.tag)

      click_link 'Join'
    end

    it 'has send button' do
      expect(find('//form/div/span/button')).to have_content ''
    end

    context 'messages', js: true do
      before :each do
        message = FactoryGirl.create(:message, user: user, hashtag: hashtag, created_at: Time.now)
        visit hashtag_path(hashtag.tag)
        page.execute_script("add_chat_message(#{message.serialize})")
      end

      it 'have content' do
        expect(page).to have_content 'Hello World!'
      end

      it 'have a thumbnail' do
        expect(find('.img-circle')).to have_content ''
      end

      it 'have name over @UsernameMention' do
        expect(page).to have_content 'Hello World! @asd asd'
      end

      it 'have #hashtag after autolinking' do
        expect(page).to have_content 'Hello World! @asd asd #avantouinti'
      end
    end

    it 'has unread marker', js: true do
      UserHashtag.find_by(user_id: user.id, hashtag_id: hashtag.id).update_attribute(:last_visited, 1.days.ago)
      
      message = FactoryGirl.create(:message, user: user, hashtag: hashtag, created_at: Time.now)
      visit hashtag_path(hashtag.tag)

      json = { 'event': 'messages', 'messages': hashtag.messages.map { |m| JSON.parse(m.serialize) } }
      page.execute_script("add_multiple_messages(#{JSON.generate(json)})")
      
      expect(page).to have_content 'Since'
    end

    it 'can send a message', js: true do
      fill_in('input-text', with: 'Hello world!')
      click_button('send')

      expect(page).to have_content('Hello world!')
    end
  end
end
