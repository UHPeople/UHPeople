require 'rails_helper'

RSpec.describe User do
  it 'list page has users' do
    FactoryGirl.create(:user)
    visit users_path

    expect(page).to have_content 'asd asd'
  end

  it 'creation fails with no name' do
    visit users_path
    click_link('Add new user')

    find('#user_campus_city_centre_campus').click
    click_button('Create')

    expect(described_class.count).to eq 0
  end

  it 'creation fails with no campus' do
    visit users_path
    click_link('Add new user')

    fill_in('name', with: 'Matti Meilahti')
    click_button('Create')

    expect(described_class.count).to eq 0
  end

  it 'creation works with name and campus', js: true do
    visit users_path
    click_link('Add new user')

    fill_in('name', with: 'Matti Meilahti')
    find('#user_campus_city_centre_campus').click

    click_button('Create')

    expect(described_class.count).to eq 1
  end

  it 'is directed to three hash if less than three interests', js: true do
    visit users_path
    click_link('Add new user')

    fill_in('name', with: 'Matti Meilahti')
    find('#user_campus_city_centre_campus').click

    click_button('Create')

    expect(page.current_path).to eq '/threehash'
  end
end
