require 'spec_helper'

describe UserHashtag do

  it "is not saved without hashtag id" do
    userHashtag = UserHashtag.create user_id: "1"

    expect(userHashtag.valid?).to be(false)
    expect(UserHashtag.count).to eq(0)
  end

  it "is not saved without user id" do
    userHashtag = UserHashtag.create hashtag_id: "1"

    expect(userHashtag.valid?).to be(false)
    expect(UserHashtag.count).to eq(0)
  end

  it "is saved with proper id's" do
    userHashtag = UserHashtag.create hashtag_id: "1", user_id: "1"

    expect(userHashtag.valid?).to be(true)
    expect(UserHashtag.count).to eq(1)
  end

  it "is saved with favourite_bool" do
    userHashtag = UserHashtag.create hashtag_id: "1", user_id: "1", favourite: true

    expect(userHashtag.valid?).to be(true)
    expect(UserHashtag.count).to eq(1)
  end


end
