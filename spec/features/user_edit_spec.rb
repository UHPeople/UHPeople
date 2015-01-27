
require 'spec_helper'

describe "User" do
  let!(:user){FactoryGirl.create :user}

  it "after editing users name and about, shows right information on user page" do
    visit edit_user_path(user)
    fill_in('user_name', with:'Vaihdettu Nimi')
    fill_in('user_about', with:'Hauska tyyppi.')
    click_button('Update User')

    expect(page).to have_content 'User was successfully updated.'
    expect(page).to have_content 'Vaihdettu Nimi'
    expect(page).to have_content 'Hauska tyyppi.'
  end
end