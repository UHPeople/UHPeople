require 'spec_helper'

describe "User list page" do
  it "has users" do
  	user = FactoryGirl.create(:user)
  	user.save
  	
    visit "/users/"

    expect(page).to have_content 'asd asd'
  end
end