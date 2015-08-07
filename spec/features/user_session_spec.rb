require 'rails_helper'

RSpec.describe User do
  let!(:user) { FactoryGirl.create :user }

  it 'is not logged in at first' do
    visit '/users'

    expect(page).to have_content 'Login as'
  end

  it 'can login' do
    visit "/login/#{user.id}"

    expect(page).to have_content 'asd asd'
    expect(page).to have_content 'Logout'
  end

  it 'can logout' do
    visit "/login/#{user.id}"
    visit logout_path

    expect(page).not_to have_content 'Logout'
    expect(page).to have_content 'Login'
  end

  it 'is directed to three hash if less than three intrests' do
    visit "/login/#{user.id}"

    expect(page).to have_content 'asd asd'
    expect(page).to have_content 'Tell us about yourself!'
  end
end
