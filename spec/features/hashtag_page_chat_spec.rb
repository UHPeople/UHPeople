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
      expect(find('//form/div/span/button/i')).to have_content 'send'
    end

    context 'messages', js: true do
      before :each do
        message = FactoryGirl.create(:message, user: user, hashtag: hashtag, created_at: Time.now)
        visit hashtag_path(hashtag.tag)
        page.execute_script("add_message(#{message.serialize})")
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

      it 'has zero likes if not any' do
        expect(find('.like-badge')).to have_content '0'
      end

      it 'thumb changes color if pressed' do
        expect(page).not_to have_css('.like-icon-liked')
        click_link('thumb_up')

        expect(page).to have_css('.like-icon-liked')
      end
    end
    context 'messages with second user', js: true do

      before :each do
        user2 = FactoryGirl.create(:user, name:'user2', username:'asd2')
        hashtag.users << user2
        FactoryGirl.create(:message, user: user2, hashtag: hashtag, created_at: Time.now)
        visit feed_index_path
        user.user_hashtags.find_by( hashtag_id: hashtag.id ).update_attribute(:last_visited, 666.days.ago)
      end

      it 'has unread marker' do
        visit hashtag_path(hashtag.tag)
        json = { 'event': 'messages', 'messages': hashtag.messages.map { |m| JSON.parse(m.serialize(user)) } }
        page.execute_script("add_multiple_messages(#{JSON.generate(json)})")
        expect(page).to have_content 'Since'
      end
    end

    # it 'can send a message' do
    #   visit hashtag_path(hashtag.tag)
    #   fill_in('input-text', with: 'Hello world!')
    #   click_button('send')
    #   expect(page).to have_content('Hello world!')
    # end
  end
end
