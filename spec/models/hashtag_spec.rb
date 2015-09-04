require 'rails_helper'

RSpec.describe Hashtag do
  it 'has the tag set correctly' do
    hashtag = described_class.new tag: 'avantouinti'

    expect(hashtag.tag).to eq('avantouinti')
  end

  it 'is not saved without a tag' do
    hashtag = described_class.create

    expect(hashtag.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  it 'is saved with a tag' do
    hashtag = described_class.create tag: 'avantouinti'

    expect(hashtag.valid?).to be(true)
    expect(described_class.count).to eq(1)
  end

  it 'is not saved with non-unique tag' do
    hashtag1 = described_class.create tag: 'avantouinti'
    hashtag2 = described_class.create tag: 'avantouinti'

    expect(hashtag1.valid?).to be(true)
    expect(hashtag2.valid?).to be(false)
    expect(described_class.count).to eq(1)
  end

  it 'is not saved with invalid tag' do
    hashtag = described_class.create tag: '-=sa2c1-##'
    expect(hashtag.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  it 'has correct file name for cover photo' do
    file = File.new(File.join(Rails.root, '/spec/fixtures/paperclip', 'blank.jpg'), 'rb')
    hashtag = described_class.create!(tag: 'test', cover_photo: file)

    assert_equal 'blank.jpg', hashtag.cover_photo_file_name
  end

  it 'can give latest message' do
    hashtag = described_class.create tag: 'avantouinti'
    user = User.create username: 'user', name: 'user'
    
    hashtag.users << user
    hashtag.save

    message = Message.create hashtag: hashtag, user: user, content: 'content'
    
    expect(hashtag.valid?).to be(true)
    expect(user.valid?).to be(true)
    expect(message.valid?).to be(true)

    expect(hashtag.latest_message).to eq(message)
  end

  it 'is empty with no messages' do
    hashtag = described_class.create tag: 'avantouinti'
    expect(hashtag.empty?).to be(true)
  end

  it 'is not empty with messages' do
    hashtag = described_class.create tag: 'avantouinti'
    user = User.create username: 'user', name: 'user'
    
    hashtag.users << user
    hashtag.save

    message = Message.create hashtag: hashtag, user: user, content: 'content'
    expect(hashtag.empty?).to be(false)
  end
end
