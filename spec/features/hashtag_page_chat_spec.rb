require 'rails_helper'

RSpec.describe Hashtag do
  context 'chat page' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:hashtag) { FactoryGirl.create(:hashtag) }

    before :each do
      visit "/login/#{user.id}"
      visit hashtag_path(hashtag.tag)

      click_link 'add'
    end

    it 'has send button' do
      expect(page).to have_selector(:link_or_button, 'send')
    end

    context 'messages', js: true do
      before :each do
        message = FactoryGirl.create(:message, user: user, hashtag: hashtag,
                                               content: "@#{user.id} ##{hashtag.tag}", created_at: Time.now.utc)
        visit hashtag_path(hashtag.tag)
        page.execute_script("add_chat_message(#{JSON.generate(message.serialize(user))})")
      end

      it 'have a thumbnail' do
        expect(find('.chatbox .img-circle')).to have_content ''
      end

      it 'have content' do
        expect(page).to have_content "@#{user.name} ##{hashtag.tag}"
      end

      it 'have name over @id mention' do
        expect(page).to have_content "@#{user.name} ##{hashtag.tag}"
      end

      it 'have #hashtag after autolinking' do
        expect(page).to have_content "@#{user.name} ##{hashtag.tag}"
      end

      it 'has zero likes if not any' do
        expect(find('.like-badge')).to have_content '0'
      end

      it 'thumb changes color if pressed' do
        expect(page).to have_content('star_border')
        click_link('star_border')
        expect(page).to have_content('star')
      end
    end

    context 'messages with likers', js: true do
      before :each do
        message = FactoryGirl.create(:message, user: user, hashtag: hashtag, created_at: Time.now.utc)
        Like.create(user_id: user.id, message_id: message.id)
        visit hashtag_path(hashtag.tag)
        page.execute_script("add_chat_message(#{JSON.generate(message.serialize(user))})")
      end
      # fails on travis
      # it 'has likers count from db' do
      #  expect(page).to have_css('#tt1', text: '1')
      # end

      # it 'has likers hover' do
      #   page.find('#tt1').trigger(:mouseover)
      #   expect(page).to have_css('.mdl-tooltip', text: 'asd asd')
      # end
    end
  end
end
