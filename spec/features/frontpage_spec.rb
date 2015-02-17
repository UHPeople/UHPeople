require 'spec_helper'

describe "Frontpage page" do
  it "has login button" do
    visit root_path
    expect(page).to have_content 'Login'
  end

  it "redirects to feed" do
    user = FactoryGirl.create(:user)
    visit "/login/#{user.id}"
    
    visit root_path
    expect(page.current_path).to eq "/feed"
  end
end