require 'rails_helper'

RSpec.describe 'Navbar' do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  before :each do
    visit "/login/#{user.id}"
  end

  it 'restarts tour', js: true do
    visit feed_index_path
    execute_script '$.post( "/firsttime/false");'

    visit feed_index_path

    first('#menu-lower-right').click
    click_link 'Start tour'

    expect(page).to have_content 'Hello and welcome to UHPeople!'
  end
end
