require 'spec_helper'

describe Hashtag do
  it "has the tag set correctly" do
    hashtag = Hashtag.new tag:"avantouinti"

    hashtag.tag.should == "avantouinti"
  end

  it "is not saved without a tag" do
    hashtag = Hashtag.create

    expect(hashtag.valid?).to be(false)
    expect(Hashtag.count).to eq(0)
  end

  it "is saved with a tag" do
    hashtag = Hashtag.create tag: "avantouinti"

    expect(hashtag.valid?).to be(true)
    expect(Hashtag.count).to eq(1)
  end

  it "is not saved with non-unique tag" do
    hashtag1 = Hashtag.create tag: "avantouinti"
    hashtag2 = Hashtag.create tag: "avantouinti"

    expect(hashtag1.valid?).to be(true)
    expect(Hashtag.count).to eq(1)
  end
end
