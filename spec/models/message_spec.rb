require 'rails_helper'

describe Message do
  it 'is not saved without hashtag id' do
    message = described_class.create content: '', hashtag_id: '', user_id: '1'

    expect(message.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  it 'is not saved without user id' do
    message = described_class.create content: '', hashtag_id: '1', user_id: ''

    expect(message.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  it 'is not saved if empty' do
    message = described_class.create content: '', hashtag_id: '1', user_id: '1'

    expect(message.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  it 'is saved with content' do
    message = described_class.create content: 'Hello World!', hashtag_id: '1', user_id: '1'

    expect(message.valid?).to be(true)
    expect(described_class.count).to eq(1)
  end
end
