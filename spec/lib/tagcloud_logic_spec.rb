require 'rails_helper'
require_relative '../../lib/tagcloud_logic'

RSpec.describe TagcloudLogic do
  subject { described_class.new }
  
  let!(:user) { FactoryGirl.create :user }
  let!(:hashtag) { FactoryGirl.create :hashtag }

  before :each do  
    user.hashtags << hashtag
    Message.create user: user, hashtag: hashtag, content: 'asd'
  end

  it 'sorts with top' do
    to_sort = (0..50).collect { |i| { text: "tag#{i}", weight: i, link: "/hashtags/#{i}" } }
    top = subject.top(to_sort)

    expect(top.count).to eq 30
    (0..29).each do |i|
      tag = top[i]
      j = (50 - i)

      expect(tag[:text]).to eq "tag#{j}"
      expect(tag[:weight]).to eq j
      expect(tag[:link]).to eq "/hashtags/#{j}"
    end
  end

  context 'scores' do
    it 'scores a hashtag' do
      score = subject.score(hashtag)

      expect(score).to eq 1
    end

    it 'old messages don\'t count' do
      message = Message.create user: user, hashtag: hashtag, content: 'asdasd'
      message.created_at = 3.weeks.ago
      message.save

      expect(subject.score(hashtag)).to eq 1
    end

    it 'old users don\t count as much' do
      usertag = user.user_hashtags.first
      usertag.created_at = 3.weeks.ago
      usertag.save

      expect(subject.score(hashtag)).to eq 0.75
    end
  end

  it 'makes cloud' do
    cloud = subject.make_cloud

    expect(cloud[0][:text]).to eq hashtag.tag
    expect(cloud[0][:weight]).to eq 1
    expect(cloud[0][:link]).to eq "/hashtags/#{hashtag.id}"
  end
end
