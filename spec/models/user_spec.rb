require 'rails_helper'

RSpec.describe User do
  it 'has name set correctly' do
    user = described_class.new name: 'Tero Testaaja'

    expect(user.name).to eq('Tero Testaaja')
  end

  it 'is saved with all needed variables' do
    user = described_class.create username: 'terotest', name: 'Tero Testaaja', campus: 'testcampus'

    expect(user.valid?).to be(true)
    expect(user.name).to eq('Tero Testaaja')
    expect(user.username).to eq('terotest')
    expect(user.campus).to eq('testcampus')
    expect(described_class.count).to eq(1)
  end

  it 'is not saved without name' do
    user = described_class.create username: 'terotest'

    expect(user.valid?).to be(false)
    expect(described_class.count).to eq(0)
  end

  context 'has active and unactive channels' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:hashtag) { FactoryGirl.create(:hashtag) }
    let!(:user_hashtag) { UserHashtag.create(user: user, hashtag: hashtag) }
    let!(:message) {Message.create(content: 'aasd', user: user, hashtag: hashtag)}

    it 'has user_hashtag is in most_active_channels' do
      expect(user.six_most_active_channels.count).to be(1)
    end

    it 'has unactive channels empty' do
      expect(user.unactive_channels.count).to be(0)
    end
    it 'has unactive channel with one' do
      hashtag2 = Hashtag.create tag: 'avantouinti2'
      UserHashtag.create(user: user, hashtag: hashtag2)
      expect(user.unactive_channels.count).to be(1)
    end
    it 'has hashtag moved to active channels' do
      hashtag2 = Hashtag.create tag: 'avantouinti2'
      UserHashtag.create(user: user, hashtag: hashtag2)
      Message.create(content: 'aasd', user: user, hashtag: hashtag2)
      expect(user.unactive_channels.count).to be(0)
      expect(user.six_most_active_channels.count).to be(2)
    end
  end
end
