require 'rails_helper'

RSpec.describe User do
  it 'list page has users' do
    FactoryGirl.create(:user)
    visit users_path

    expect(page).to have_content 'asd asd'
  end

  it 'user creation fails with no name' do
    visit users_path
    click_link('Add new user')

    click_button('Update')

    expect(described_class.count).to eq 0
  end
end
