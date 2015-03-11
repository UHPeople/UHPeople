require 'rails_helper'

RSpec.describe User do
  it 'list page has users' do
    user = FactoryGirl.create(:user)
    user.save

    visit '/users/'

    expect(page).to have_content 'asd asd'
  end
end
