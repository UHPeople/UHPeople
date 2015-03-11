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
end
