require 'rails_helper'

RSpec.describe 'Search page' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
    visit "/hashtags/#{hashtag.id}"

    click_link 'Join'
  end

  it 'creates hashtags' do
    visit '/search?search=asd'
    find("//div[@id='new_hashtag']/p/a").click
    expect(page.current_path).to eq "/hashtags/#{hashtag.id + 1}"
  end

  it 'finds user with exact match' do
    visit "/search?search=#{user.name}"
    find("//div[@id='users']/h3/a").click
    expect(page.current_path).to eq "/users/#{user.id}"
  end

  it 'finds user with non-exact match' do
    visit '/search?search=a'
    find("//div[@id='users']/h3/a").click
    expect(page.current_path).to eq "/users/#{user.id}"
  end

  it 'finds hashtag with exact match' do
    visit "/search?search=#{hashtag.tag}"
    find("//div[@id='hashtags']/h3/a").click
    expect(page.current_path).to eq "/hashtags/#{hashtag.id}"
  end

  it 'finds hashtag with non-exact match' do
    visit '/search?search=a'
    find("//div[@id='hashtags']/h3/a").click
    expect(page.current_path).to eq "/hashtags/#{hashtag.id}"
  end

  it 'doesn\'t suggest invalid hashtags' do
    visit '/search?search=%23asd'
    expect(page).to have_content 'No results for: #asd'
  end
end
