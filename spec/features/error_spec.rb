require 'rails_helper'

RSpec.describe 'Error pages' do
  let!(:user) { FactoryGirl.create(:user) }

  before :each do
    visit "/login/#{user.id}"
  end

  it 'has an error page for 404' do
    visit '/404'
    expect(page).to have_content 'something went wrong'
  end

  it 'has an error page for 422' do
    visit '/422'
    expect(page).to have_content 'something went wrong'
  end

  it 'has an error page for 500' do
    visit '/500'
    expect(page).to have_content 'something went wrong'
  end
end
