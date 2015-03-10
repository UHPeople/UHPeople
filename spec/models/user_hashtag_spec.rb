require 'rails_helper'

RSpec.describe UserHashtag do
  it 'is not saved without hashtag id' do
    user_hashtag = described_class.create user_id: '1'

    expect(user_hashtag.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  it 'is not saved without user id' do
    user_hashtag = described_class.create hashtag_id: '1'

    expect(user_hashtag.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  it "is saved with proper id's" do
    user_hashtag = described_class.create hashtag_id: '1', user_id: '1'

    expect(user_hashtag.valid?).to be(true)
    expect(described_class.count).to eq(1)
  end

  it 'is saved with favourite_bool' do
    userHashtag = described_class.create hashtag_id: '1', user_id: '1', favourite: true

    expect(userHashtag.valid?).to be(true)
    expect(described_class.count).to eq(1)
  end
end
