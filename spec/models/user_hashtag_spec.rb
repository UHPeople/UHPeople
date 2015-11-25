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
    user_hashtag = described_class.create hashtag_id: '1', user_id: '1', favourite: true

    expect(user_hashtag.valid?).to be(true)
    expect(described_class.count).to eq(1)
  end

  it 'is not saved twice on same person and hashtag' do
    described_class.create hashtag_id: '1', user_id: '1'
    user_hashtag = described_class.create hashtag_id: '1', user_id: '1'

    expect(user_hashtag.valid?).to be(false)
    expect(described_class.count).to eq(1)
  end

  context 'unread_messages' do
    it 'is 0 with no messages' do
      user = FactoryGirl.create :user
      hashtag = FactoryGirl.create :hashtag

      user_hashtag = described_class.create hashtag: hashtag, user: user, last_visited: nil

      expect(user_hashtag.unread_messages).to eq(0)
    end

    it 'is all messages when none are read' do
      user = FactoryGirl.create :user
      hashtag = FactoryGirl.create :hashtag

      user_hashtag = described_class.create hashtag: hashtag, user: user, last_visited: nil
      FactoryGirl.create(:message, user: user, hashtag: hashtag)

      expect(user_hashtag.unread_messages).to eq(1)
    end

    it 'is only new messages when some are read' do
      user = FactoryGirl.create :user
      hashtag = FactoryGirl.create :hashtag

      user_hashtag = described_class.create hashtag: hashtag, user: user, last_visited: Time.zone.now

      FactoryGirl.create(:message, user: user, hashtag: hashtag, created_at: 1.day.ago)
      FactoryGirl.create(:message, user: user, hashtag: hashtag)

      hashtag.update_attribute(:updated_at, 1.day.ago)

      expect(user_hashtag.unread_messages).to eq(1)
    end

    it 'is 0 when all messages are read' do
      user = FactoryGirl.create :user
      hashtag = FactoryGirl.create :hashtag

      user_hashtag = described_class.create hashtag: hashtag, user: user, last_visited: Time.current

      FactoryGirl.create(:message, user: user, hashtag: hashtag, created_at: 2.days.ago)
      FactoryGirl.create(:message, user: user, hashtag: hashtag, created_at: 1.day.ago)

      hashtag.update_attribute(:updated_at, 1.day.ago)

      expect(user_hashtag.unread_messages).to eq(0)
    end
  end
end
