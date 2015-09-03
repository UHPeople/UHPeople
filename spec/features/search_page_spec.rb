require 'rails_helper'

RSpec.describe 'Search page' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
    visit "/hashtags/#{hashtag.tag}"

    click_link 'Join'
  end

  it 'creates hashtags' do
    visit '/search?search=hashtag'
    find("//div[@id='new_hashtag']/div/a").click
    expect(page.current_path).to eq '/hashtags/hashtag'
  end

  it 'finds user with exact match' do
    user.update_attribute('username', user.username + '2')
    user.update_attribute('name', user.name + '2')
    FactoryGirl.create(:user)

    visit "/search?search=#{user.name}"
    expect(page).to have_content user.name
  end

  it 'finds user with non-exact match' do
    visit '/search?search=a'
    first("//div[@id='users']/div/div/h4/a").click
    expect(page.current_path).to eq "/users/#{user.id}"
  end

  it 'finds hashtag with exact match' do
    hashtag.update_attribute('tag', hashtag.tag+'2')
    hashtag2 = FactoryGirl.create(:hashtag)

    visit "/search?search=#{hashtag2.tag}"
    first("//div[@id='hashtags']/div/div/h4/a").click
    expect(page.current_path).to eq "/hashtags/#{hashtag2.tag}"
  end

  it 'finds hashtag with non-exact match' do
    visit '/search?search=' + hashtag.tag[0]
    find("//div[@id='hashtags']/div/div/h4/a").click
    expect(page.current_path).to eq "/hashtags/#{hashtag.tag}"
  end

  it 'doesn\'t suggest invalid hashtags' do
    visit '/search?search=%23%23asd'
    expect(page).to have_content 'No results for: ##asd'
  end

  it 'strips hashtag' do
    hashtag.update_attribute('tag', hashtag.tag+'2')
    hashtag2 = FactoryGirl.create(:hashtag)

    visit "/search?search=%23#{hashtag2.tag}"
    expect(page).to have_content "Search results for channels: ##{hashtag2.tag}"
  end

  describe 'redirects to' do
    it 'single hashtag' do
      visit "/search?search=#{hashtag.tag}"
      expect(page.current_path).to eq "/hashtags/#{hashtag.tag}"
    end

    it 'single user' do
      visit "/search?search=#{user.name}"
      expect(page.current_path).to eq "/users/#{user.id}"
    end
  end

  describe 'on users results' do
    it 'shows about-me' do
      visit '/search?search=a'
      expect(page).to have_content user.about
    end

    it 'shows hashtags memberships' do
      hashtag.update_attribute('tag', hashtag.tag+'2')
      hashtag2 = FactoryGirl.create(:hashtag)
      visit "/hashtags/#{hashtag2.tag}"
      click_link 'Join'

      visit '/search?search=asd'

      expect(page).to have_content "Member of ##{hashtag.tag} ##{hashtag2.tag} ..."
    end
  end

  describe 'on hashtag results' do
    it 'shows topic' do
      hashtag.update_attribute('topic', 'test topic')

      visit '/search?search=a'
      expect(page).to have_content "#{hashtag.topic}"
    end

    it 'shows member count' do
      visit '/search?search=a'
      expect(page).to have_content "#{hashtag.users.count} member"
    end

    it 'shows timestamp for latest message' do
      Message.create hashtag: hashtag, user: user, content: 'content', created_at: Time.zone.now

      visit '/search?search=a'
      expect(page).to have_content "Latest message"
    end
  end
end
