require 'rails_helper'
require_relative '../../lib/chat_backend'

RSpec.describe UHPeople::ChatBackend do
  # TODO: RSpec Mock
  class MockSocket
    def initialize
      @sent = []
    end

    def send(data)
      @sent << JSON.parse(data)
    end

    def close
      @sent << 'closed'
    end

    attr_reader :sent
  end

  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  let!(:socket) { MockSocket.new }

  let!(:app) { -> { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }
  subject { described_class.new app  }

  it 'serializes messages' do
    hashtag.users << user
    message = Message.create content: '<h1>asd</h1>', user: user, hashtag: hashtag

    serialized_json = subject.serialize message
    serialized = JSON.parse serialized_json

    expect(serialized['content']).to eq '&lt;h1&gt;asd&lt;/h1&gt;'
  end

  it 'responds with error to invalid user' do
    message = { 'event': 'online', 'user': -1, 'hashtag': hashtag.id }
    subject.respond(socket, message)

    expect(socket.sent.last['event']).to eq 'error'
    expect(socket.sent.last['content']).to eq 'Invalid User id'
  end

  # it 'responds with error to invalid hashtag' do
  #  message = { 'event': 'online', 'user': user.id, 'hashtag': -1 }
  #  subject.respond(socket, message)
  #  expect(socket.sent.last['event']).to eq 'error'
  #  expect(socket.sent.last['content']).to eq 'Invalid hashtag id'
  # end

  # it 'responds to online event' do
  #  message = { 'event': 'online', 'user': user.id, 'hashtag': hashtag.id }
  #  subject.respond(socket, message)
  #  expect(socket.sent.last['event']).to eq 'online'
  #  expect(socket.sent.last['onlines'].count).to eq 1
  # end

  # it 'responds to message event' do
  #  message = { 'event': 'message', 'content': 'asd', 'user': user.id, 'hashtag': hashtag.id }
  #  subject.respond(socket, message)
  #  expect(socket.sent.last['event']).to eq 'message'
  #  expect(socket.sent.last['content'].count).to eq 'asd'
  # end

  # it 'responds to feed event' do
  # message = { 'event': 'feed', 'user': user.id }
  # subject.respond(socket, message)

  # expect(socket.sent.last['event']).to eq 'feed'
  # end

  context 'ClientList' do
    it 'adds one online user' do
      subject.add_client(socket, user.id, hashtag.id)

      onlines_json = subject.online_users(hashtag.id)
      onlines = JSON.parse(onlines_json)

      expect(onlines['event']).to eq 'online'
      expect(onlines['onlines'].count).to eq 1
    end

    it 'adds two online users' do
      subject.add_client(socket, user.id, hashtag.id)
      subject.add_client(socket, user.id + 1, hashtag.id)

      onlines_json = subject.online_users(hashtag.id)
      onlines = JSON.parse(onlines_json)

      expect(onlines['event']).to eq 'online'
      expect(onlines['onlines'].count).to eq 2
    end

    it 'removes duplicate online users' do
      subject.add_client(socket, user.id, hashtag.id)

      socket2 = MockSocket.new
      subject.add_client(socket2, user.id, hashtag.id)

      onlines_json = subject.online_users(hashtag.id)
      onlines = JSON.parse(onlines_json)

      expect(onlines['event']).to eq 'online'
      expect(onlines['onlines'].count).to eq 1

      expect(socket.sent.last).to eq 'closed'
    end

    it 'removes online users' do
      subject.add_client(socket, user.id, hashtag.id)

      subject.remove_client socket

      onlines_json = subject.online_users(hashtag.id)
      onlines = JSON.parse(onlines_json)

      expect(onlines['event']).to eq 'online'
      expect(onlines['onlines'].count).to eq 0
    end

    it 'empty hashtag gives empty onlines' do
      subject.add_client(socket, user.id, hashtag.id)

      onlines_json = subject.online_users(hashtag.id + 1)
      onlines = JSON.parse(onlines_json)

      expect(onlines['event']).to eq 'online'
      expect(onlines['hashtag']).to eq hashtag.id + 1
      expect(onlines['onlines'].count).to eq 0
    end

    it 'handles multiple hashtags' do
      # hashtags = user.hashtags.map(&:id)
      subject.add_client socket, user.id, [1, 2]

      onlines_json = subject.online_users(1)
      onlines = JSON.parse(onlines_json)
      expect(onlines['onlines'].count).to eq 1

      onlines_json = subject.online_users(2)
      onlines = JSON.parse(onlines_json)
      expect(onlines['onlines'].count).to eq 1
    end
  end
end
