require 'spec_helper'

describe "Frontpage page" do

  it "has login button" do

    visit "/"
    expect(page).to have_content 'Login'
  end
end