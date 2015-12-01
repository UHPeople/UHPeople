require 'rails_helper'

RSpec.describe 'About page' do
  let!(:user) { FactoryGirl.create(:user) }

  before :each do
    visit "/login/#{user.id}"
    visit about_index_path
  end

  it 'has information' do
    expect(page).to have_content 'About UHPeople'
  end
end
