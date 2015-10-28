require 'rails_helper'

RSpec.describe Like do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }
  let!(:user_hashtag) { UserHashtag.create(user: user, hashtag: hashtag) }
  let!(:message) { FactoryGirl.create(:message, user: user, hashtag: hashtag)}

  it 'has user set' do
    like = described_class.new user: user
    expect(like.user).to eq user
  end

  it 'has message set' do
    like = described_class.new message: message
    expect(like.message).to eq message
  end

  it 'is saved' do
    described_class.create user: user, message: message
    expect(described_class.count).to eq 1
  end

  it 'is not saved with missing user' do
    described_class.create message: message
    expect(described_class.count).to eq 0
  end

  it 'is not saved with missing message' do
    described_class.create user: user
    expect(described_class.count).to eq 0
  end

  it 'is not saved with non-unique message-user-combo' do
    described_class.create user: user, message: message
    like = described_class.create user: user, message: message
    expect(like.valid?).to be false
    expect(described_class.count).to eq 1
  end
end
