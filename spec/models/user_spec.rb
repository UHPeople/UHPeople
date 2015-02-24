require 'spec_helper'

describe User do

  it "has name set correctly" do
    user = User.new name:"Tero Testaaja"

    user.name.should == "Tero Testaaja"
  end

  it "is saved with all needed variables" do
    user = User.create username:"terotest", name:"Tero Testaaja"

    expect(user.valid?).to be(true)
    user.name.should == "Tero Testaaja"
    user.username.should == "terotest"
    expect(User.count).to eq(1)
  end

  it "is not saved without name" do
    user = User.create username:"terotest"

    expect(user.valid?).to be(false)
    expect(User.count).to eq(0)
  end

end