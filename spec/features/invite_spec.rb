require 'rails_helper'

RSpec.describe 'Invite page' do
  let!(:user) { FactoryGirl.create(:user) }

  before :each do
    visit "/login/#{user.id}"
    visit invite_index_path
  end

  it 'has a title' do
    expect(page).to have_content 'Invite'
  end

  context 'form' do
    it 'has a submit button' do
      expect(page).to have_css 'input[type="submit"].mdl-button'
    end

    it 'has an input bar' do
      expect(page).to have_css '.mdl-textfield__input#new-invite'
    end
  end
end
