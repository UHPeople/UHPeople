require 'rails_helper'

RSpec.describe 'Frontpage page' do
  it 'has login button' do
    visit root_path
    expect(page).to have_content 'Login'
  end

  it 'redirects to feed' do
    user = FactoryGirl.create(:user)
    visit "/login/#{user.id}"

    visit root_path
    expect(page.current_path).to eq '/feed'
  end

  it 'gets redirected to from other controllers' do
    visit '/feed'
    expect(page.current_path).to eq '/'
  end

  it 'has no search bar' do
    visit root_path
    expect(page).to_not have_content 'Search'
  end
end
