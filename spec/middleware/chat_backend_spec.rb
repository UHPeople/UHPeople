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
  let!(:user_hashtag) { UserHashtag.create(user: user, hashtag: hashtag) }

  let!(:socket) { MockSocket.new }

  let!(:app) { -> { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }
  subject { described_class.new app  }

  context 'responds with error to' do
    it 'invalid user' do
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

    it 'invalid message' do
      subject.online_event(user, hashtag, socket)
      subject.message_event(user, hashtag, socket, '')

      expect(Message.count).to eq 0
      expect(socket.sent.last['event']).to eq 'error'
      expect(socket.sent.last['content']).to eq 'Invalid message'
    end
  end

  context 'on event' do
    it 'responds with messages' do
      subject.feed_event(user, socket)
      expect(socket.sent.last['event']).to eq 'messages'
    end

    it 'message adds new message' do
      subject.online_event(user, hashtag, socket)

      subject.message_event(user, hashtag, socket, 'asd')

      expect(Message.count).to eq 1
      expect(socket.sent.last['content']).to eq 'asd'
      expect(socket.sent.last['event']).to eq 'message'
    end

    it 'online adds new client' do
      subject.online_event(user, hashtag, socket)

      expect(socket.sent.last['event']).to eq 'online'
    end
  end

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

    it 'handles multiple hashtags (one user, many hashtags => on feed)' do
      subject.add_client socket, user.id, [1, 2]

      onlines_json = subject.online_users(1)
      onlines = JSON.parse(onlines_json)
      expect(onlines['onlines'].count).to eq 0

      onlines_json = subject.online_users(2)
      onlines = JSON.parse(onlines_json)
      expect(onlines['onlines'].count).to eq 0
    end

    it 'handles multiple hashtags (one user, one hashtag => on hashtags)' do
      subject.add_client socket, user.id, 1
      subject.add_client socket, user.id, 2

      onlines_json = subject.online_users(1)
      onlines = JSON.parse(onlines_json)
      expect(onlines['onlines'].count).to eq 1

      onlines_json = subject.online_users(2)
      onlines = JSON.parse(onlines_json)
      expect(onlines['onlines'].count).to eq 1
    end
  end

  context 'broadcasts to' do
    it 'empty hashtags' do
      subject.add_client socket, user.id, 0
      subject.broadcast '{ "event": "asd" }', 1

      expect(socket.sent.last).to eq nil
    end

    it 'single connected client' do
      subject.add_client socket, user.id, 1
      subject.broadcast '{ "event": "asd" }', 1

      expect(socket.sent.last['event']).to eq 'asd'
    end

    it 'all connected clients' do
      subject.add_client socket, 0, 1

      socket2 = MockSocket.new
      subject.add_client socket2, 1, 1

      subject.broadcast '{ "event": "asd" }', 1

      expect(socket.sent.last['event']).to eq 'asd'
      expect(socket2.sent.last['event']).to eq 'asd'
    end

    it 'feed clients' do
      subject.add_client socket, 0, 1

      socket2 = MockSocket.new
      subject.add_client socket2, 0, [1, 0]

      subject.broadcast '{ "event": "message" }', 1

      expect(socket.sent.last['event']).to eq 'message'
      expect(socket2.sent.last['event']).to eq 'message'
    end
  end

  it 'finds mentions' do
    subject.add_client(socket, user.id, hashtag.id)

    message = Message.create user: user, hashtag: hashtag, content: "@#{user.name}"
    subject.find_mentions(message)

    expect(socket.sent.last['event']).to eq 'notification'
  end
end
