require 'rails_helper'

RSpec.describe Message do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  it 'is not saved without hashtag id' do
    message = described_class.create content: 'asd', hashtag_id: '', user_id: user.id

    expect(message.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  it 'is not saved without user id' do
    message = described_class.create content: 'asd', hashtag_id: hashtag.id, user_id: ''

    expect(message.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  it 'is not saved if empty' do
    message = described_class.create content: '', hashtag_id: hashtag.id, user_id: user.id

    expect(message.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  it 'is not saved if user doesn\'t belong to hashtag' do
    message = described_class.create content: 'asd', hashtag_id: hashtag.id, user_id: user.id

    expect(message.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  it 'is saved with content' do
    hashtag.users << user
    message = described_class.create content: 'asd', hashtag_id: hashtag.id, user_id: user.id

    expect(message.valid?).to be(true)
    expect(described_class.count).to eq(1)
  end
end
