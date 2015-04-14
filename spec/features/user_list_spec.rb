require 'rails_helper'

RSpec.describe User do
  it 'list page has users' do
    FactoryGirl.create(:user)
    visit users_path

    expect(page).to have_content 'asd asd'
  end

  it 'list page lets create new users' do
    visit users_path
    click_link('Add new user')

    fill_in('user_name', with: 'Nimi')
    fill_in('user_about', with: 'Hauska tyyppi.')

    click_button('Update')

    expect(described_class.count).to eq 1
  end

  it 'user creation fails with no name' do
    visit users_path
    click_link('Add new user')

    click_button('Update')

    expect(described_class.count).to eq 0
  end
end
