require 'rails_helper'

RSpec.describe Notification do
  let!(:user) { FactoryGirl.create :user }
  let!(:hashtag) { FactoryGirl.create :hashtag }

  it 'has everything set correctly' do
    notif = described_class.new notification_type: 1, tricker_user: user, tricker_hashtag: hashtag, user: user

    expect(notif.user).to eq user
    expect(notif.tricker_hashtag).to eq hashtag
    expect(notif.tricker_user).to eq user
  end

  it 'is saved with all needed variables' do
    notif = described_class.create notification_type: 1, tricker_user: user, tricker_hashtag: hashtag, user: user

    expect(notif.valid?).to be(true)
    expect(described_class.count).to eq(1)
  end

  context 'is not saved without' do
    it 'tricker user' do
      notif = described_class.create notification_type: 1, tricker_hashtag: hashtag, user: user

      expect(notif.valid?).to be(false)
      expect(described_class.count).to eq(0)
    end

    it 'user' do
      notif = described_class.create notification_type: 1, tricker_user: user, tricker_hashtag: hashtag

      expect(notif.valid?).to be(false)
      expect(described_class.count).to eq(0)
    end

    it 'tricker hashtag' do
      notif = described_class.create notification_type: 1, tricker_user: user, user: user

      expect(notif.valid?).to be(false)
      expect(described_class.count).to eq(0)
    end

    it 'notification type' do
      notif = described_class.create tricker_user: user, tricker_hashtag: hashtag, user: user

      expect(notif.valid?).to be(false)
      expect(described_class.count).to eq(0)
    end
  end
end
