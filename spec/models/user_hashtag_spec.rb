require 'spec_helper'

describe UserHashtag do
  it 'is not saved without hashtag id' do
    user_hashtag = UserHashtag.create user_id: '1'

    expect(user_hashtag.valid?).to be(false)
    expect(UserHashtag.count).to eq(0)
  end

  it 'is not saved without user id' do
    user_hashtag = UserHashtag.create hashtag_id: '1'

    expect(user_hashtag.valid?).to be(false)
    expect(UserHashtag.count).to eq(0)
  end

  it "is saved with proper id's" do
    user_hashtag = UserHashtag.create hashtag_id: '1', user_id: '1'

    expect(user_hashtag.valid?).to be(true)
    expect(UserHashtag.count).to eq(1)
  end
end
