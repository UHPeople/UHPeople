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
    find("//div[@id='new_hashtag']/p/a").click
    expect(page.current_path).to eq '/hashtags/hashtag'
  end

  it 'finds user with exact match' do
    user.update_attribute('username', 'asd2')
    FactoryGirl.create(:user)

    visit "/search?search=#{user.name}"
    expect(page).to have_content user.name
  end

  it 'finds user with non-exact match' do
    visit '/search?search=a'
    first("//div[@id='users']/h4/a").click
    expect(page.current_path).to eq "/users/#{user.id}"
  end

  it 'finds hashtag with exact match' do
    hashtag.update_attribute('tag', hashtag.tag+'2')
    hashtag2 = FactoryGirl.create(:hashtag)

    visit "/search?search=#{hashtag.tag}"
    first("//div[@id='hashtags']/h4/a").click
    expect(page.current_path).to eq "/hashtags/#{hashtag.tag}"
  end

  it 'finds hashtag with non-exact match' do
    visit '/search?search=a'
    find("//div[@id='hashtags']/h4/a").click
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

  it 'redirects to single hashtag' do
    visit "/search?search=#{hashtag.tag}"
    expect(page.current_path).to eq "/hashtags/#{hashtag.tag}"
  end

  it 'redirects to single user' do
    visit "/search?search=#{user.name}"
    expect(page.current_path).to eq "/users/#{user.id}"
  end

  describe 'on search results' do
    it 'it shows hashtag member count' do
      visit '/search?search=a'
      expect(page).to have_content "(#{hashtag.users.count} member"
    end

    it 'it shows hashtag description' do
      hashtag.update_attribute('topic', 'test topic')

      visit '/search?search=a'
      expect(page).to have_content "#{hashtag.topic}"
    end

    it 'it shows users about' do
      visit '/search?search=a'
      expect(page).to have_content "#{user.about}"
    end

    it 'it shows some users hashtags' do
      hashtag.update_attribute('tag', hashtag.tag+'2')
      hashtag2 = FactoryGirl.create(:hashtag)
      visit "/hashtags/#{hashtag2.tag}"
      click_link 'Join'
      visit '/search?search=asd'

      expect(page).to have_content "#{hashtag.tag}"
      expect(page).to have_content "#{hashtag2.tag}"
    end
  end
end
