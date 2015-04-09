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

  context 'valid message' do
    let!(:user_hashtag) { UserHashtag.create(user: user, hashtag: hashtag) }
    let!(:message) do
      described_class.create content: '<h1>asd</h1> http://localhost:3000/hashtags/2',
                             user: user,
                             hashtag: hashtag
    end

    it 'is saved' do
      expect(message.valid?).to be(true)
      expect(described_class.count).to eq(1)
    end

    it 'can be serialized and sanitized' do
      serialized_json = message.serialize
      serialized = JSON.parse serialized_json

      expect(serialized['content']).to include '&lt;h1&gt;asd&lt;/h1&gt;'
    end

    it 'content is autolinked' do
      serialized_json = message.serialize
      serialized = JSON.parse serialized_json

      expect(serialized['content']).to include '<a target="_blank" href="http://localhost:3000/hashtags/2">http://localhost:3000/hashtags/2</a>'
    end
  end
end
