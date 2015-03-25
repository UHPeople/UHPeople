require 'rails_helper'

RSpec.describe 'Feed page' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
    visit "/hashtags/#{hashtag.id}"
    click_link 'Join'
  end

  context 'feed tab' do
    before :each do
      create_and_visit
    end

    it 'has messages in feed' do
      expect(page).to have_content 'Asdasd'
    end

    it 'has messages in feed in order' do
      Message.create user: user, hashtag: hashtag, content: 'Asdasd2'

      expect(find('div.feed_chat_box:first')).to have_content 'Asdasd'
    end

    it 'has messages in favourites' do
      click_link 'Favourites'
      expect(page).to have_content 'Asdasd'
    end

    it 'redirects hashtag box link to right hashtag when tag opened' do
      first(:link, 'avantouinti').click
      expect(page).to have_content 'Asdasd'
      expect(page).to have_content 'Members'
      expect(page).to have_content 'asd asd'
    end

    it "doesn't have groups title if no hashtags" do
      visit "/hashtags/#{hashtag.id}"
      click_link 'Leave'
      visit '/feed'

      expect(page).not_to have_content 'Interests'
    end

    it 'redirects to favourites tab when changing favourites', js: true do
      find('td a.glyphicon').click

      expect(URI.parse(page.current_url).fragment).to eq 'favourites'
    end

    it 'has thumbnails' do
      expect(find('.avatar-45:first')).to have_content ''
    end
  end

  context 'favourites tab' do
    it 'is empty when no favorites' do
      create_and_visit
      click_link 'Favourites'
      expect(page).to have_content 'You have no favourites selected. Star some interests to see something here!'
    end

    it 'has the right content when favourites exist' do
      create_and_visit
      find('td a.glyphicon').click
      click_link 'Favourites'
      expect(find('div.favourites_chat_box:first-child')).to have_content 'Asdasd'
    end

    it 'is empty when favourite removed' do
      create_and_visit
      find('td a.glyphicon').click
      click_link 'Favourites'

      expect(find('div.favourites_chat_box:first-child')).to have_content 'Asdasd'
      find('td a.glyphicon').click
      click_link 'Favourites'

      expect(page).to have_content 'You have no favourites selected. Star some interests to see something here!'
    end

    it 'wont let add more than 5 favourites' do
      for i in 1..5
        hashtag =  FactoryGirl.create(:hashtag, tag: i)
        visit "/hashtags/#{hashtag.id}"
        click_link 'Join'
      end

      visit '/feed'
      page.all(:css, 'td a.glyphicon').each(&:click)

      expect(page).to have_content 'You already have 5 favourites, remove some to add a new one!'
    end

    context 'chatboxes' do
      let!(:hashtag2) { Hashtag.create tag: 'asd2000' }
      let!(:message) { Message.create user: user, hashtag: hashtag2, content: 'Asdasd2' }

      before :each do 
        create_and_visit
        page.all(:css, 'td a.glyphicon').each(&:click)
      end

      it 'are in order' do
        expect(find('.fav:first')).to have_content 'Asdasd'
      end

      it 'have timestamps formatted', js: true do
        # is not do things
        #expect(find('.fav')).to_not have_content message.timestamp
      end
    end
  end

  it 'has tagcloud', js: true do
    create_and_visit
    expect(find('span#tag_cloud_word_0')).to have_content 'avantouinti'
  end

  it 'has tagcloud with hottest tag biggest', js: true do
    hashtag3 = Hashtag.create tag: 'cloudtag2'
    Message.create user: user, hashtag: hashtag3, content: 'Asdasd3'
    Message.create user: user, hashtag: hashtag3, content: 'Asdasd4'
    Message.create user: user, hashtag: hashtag3, content: 'Asdasd5'
    
    visit '/feed'
    expect(find('span.w1')).to have_content 'cloudtag2'
  end
end

def create_and_visit
  Message.create user: user, hashtag: hashtag, content: 'Asdasd'
  visit '/feed'
end
