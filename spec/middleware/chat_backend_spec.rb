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

    def map(key)
      @sent.map { |packet| packet[key] }
    end

    attr_reader :sent
  end

  let!(:user) { FactoryGirl.create(:user) }
  let!(:user2) { FactoryGirl.create(:user, username: 'asd2') }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }
  let!(:user_hashtag) { UserHashtag.create(user: user, hashtag: hashtag, favourite: true) }

  let!(:socket) { MockSocket.new }

  let!(:app) { -> { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }
  subject { described_class.new app }

  context 'responds with error to' do
    it 'invalid user' do
      subject.online_event(socket, user.id + 1, user.token)

      expect(socket.map 'event').to include 'error'
      expect(socket.map 'content').to include 'Invalid user or token'
    end

    it 'invalid hashtag' do
      subject.online_event(socket, user, user.token)
      message = "{ \"event\": \"hashtag\", \"user\": #{user.id}, \"hashtag\": -1 }"
      subject.respond(socket, message)

      expect(socket.map 'event').to include 'error'
      expect(socket.map 'content').to include 'Invalid Hashtag'
    end

    it 'invalid message' do
      subject.online_event(socket, user, user.token)
      subject.message_event(socket, user, hashtag, '')

      expect(Message.count).to eq 0
      expect(socket.sent.last['event']).to eq 'error'
      expect(socket.sent.last['content']).to eq 'Invalid message'
    end

    it 'invalid authentication' do
      subject.online_event(socket, user.id, "token")

      expect(socket.map 'event').to include 'error'
      expect(socket.map 'content').to include 'Invalid user or token'
    end

    it 'not authenticating' do
      message = "{ \"event\": \"hashtag\", \"user\": #{user.id}, \"hashtag\": #{hashtag.id} }"
      subject.respond(socket, message)

      expect(socket.map 'event').to include 'error'
      expect(socket.map 'content').to include 'Not authenticated'
    end
  end

  context 'on' do
    context 'feed event' do
      it 'responds with messages' do
        subject.online_event(socket, user, user.token)
        subject.feed_event(socket, user)
        expect(socket.sent.last['event']).to eq 'feed'
      end

      # it 'subscribes client to feed messages' do
    end

    context 'favourites event' do
      it 'responds with messages' do
        subject.message_event(socket, user, hashtag, 'asd')

        subject.online_event(socket, user, user.token)
        subject.favourites_event(socket, user)

        expect(socket.sent.last['event']).to eq 'favourites'
        expect(socket.sent.last['messages'].last['content']).to eq 'asd'
      end

      # it 'subscribes client to favourites messages' do
      #   subject.online_event(socket, user, user.token)
      #   subject.favourites_event(socket, user)
      #
      #   subject.message_event(socket, user, hashtag, 'asd')
      #
      #   expect(socket.sent.last['event']).to eq 'message'
      # end
    end

    context 'like event' do
      it 'fails with invalid like' do
        subject.online_event(socket, user, user.token)
        subject.like_event(socket, user, nil)

        expect(Like.count).to eq 0
      end

      it 'creates like' do
        message = FactoryGirl.create :message, user: user, hashtag: hashtag

        subject.online_event(socket, user, user.token)
        subject.like_event(socket, user, message)

        expect(Like.count).to eq 1
      end

      it 'creates like' do
        message = FactoryGirl.create :message, user: user, hashtag: hashtag

        subject.online_event(socket, user, user.token)
        subject.like_event(socket, user, message)

        expect(Like.count).to eq 1
      end

      it 'sends like once if subscribed' do
        message = FactoryGirl.create :message, user: user, hashtag: hashtag

        subject.online_event(socket, user, user.token)
        subject.subscribe(socket, [hashtag.id])
        subject.like_event(socket, user, message)

        expect(socket.map 'event').to include 'like'
        expect(socket.map('event').count('like')).to eq 1
      end

      it 'sends like even if not subscribed' do
        message = FactoryGirl.create :message, user: user, hashtag: hashtag

        subject.online_event(socket, user, user.token)
        subject.like_event(socket, user, message)

        expect(socket.map 'event').to include 'like'
      end
    end

    context 'dislike event' do
      it 'fails with invalid like' do
        message = FactoryGirl.create :message, user: user, hashtag: hashtag

        subject.online_event(socket, user, user.token)
        subject.like_event(socket, user, message)
        subject.dislike_event(socket, user, nil)

        expect(Like.count).to eq 1
      end

      it 'removes like' do
        message = FactoryGirl.create :message, user: user, hashtag: hashtag

        subject.online_event(socket, user, user.token)
        subject.like_event(socket, user, message)
        subject.dislike_event(socket, user, message)

        expect(Like.count).to eq 0
      end

      it 'responds with dislike' do
        message = FactoryGirl.create :message, user: user, hashtag: hashtag

        subject.online_event(socket, user, user.token)
        subject.subscribe(socket, [hashtag.id])
        subject.like_event(socket, user, message)
        subject.dislike_event(socket, user, message)

        expect(socket.map 'event').to include 'dislike'
      end
    end

    context 'message event' do
      it 'adds new message' do
        subject.online_event(socket, user, user.token)
        subject.hashtag_event(socket, user, hashtag, nil)

        subject.message_event(socket, user, hashtag, 'asd')

        expect(Message.count).to eq 1
        expect(socket.map 'event').to include 'message'
        expect(socket.map 'content').to include 'asd'
      end
    end

    context 'online event' do
      it 'responds with online users' do
        subject.online_event(socket, user, user.token)
        expect(socket.map 'event').to include 'online'
      end
    end

    context 'messages event' do
    end
  end

  context 'ClientList' do
    it 'adds one user' do
      subject.add_client(socket, user)

      onlines_json = subject.online_users
      onlines = JSON.parse(onlines_json)

      expect(onlines['event']).to eq 'online'
      expect(onlines['onlines'].count).to eq 1
    end

    it 'removes online users' do
      subject.add_client(socket, user)

      subject.remove_client socket

      onlines_json = subject.online_users
      onlines = JSON.parse(onlines_json)

      expect(onlines['event']).to eq 'online'
      expect(onlines['onlines'].count).to eq 0
    end
  end

  context 'broadcasts to' do
    it 'empty hashtags' do
      subject.online_event(socket, user, user.token)
      subject.subscribe(socket, hashtag.id)
      subject.broadcast '{ "event": "asd" }', hashtag.id + 1

      expect(socket.map 'event').to_not include 'asd'
    end

    it 'single connected client' do
      subject.online_event(socket, user, user.token)
      subject.subscribe(socket, hashtag.id)

      subject.broadcast '{ "event": "asd" }', hashtag.id

      expect(socket.map 'event').to include 'asd'
    end

    it 'all connected clients' do
      socket2 = MockSocket.new
      subject.online_event(socket, user, user.token)
      subject.online_event(socket2, user2, user2.token)

      subject.broadcast '{ "event": "asd" }'

      expect(socket.map 'event').to include 'asd'
      expect(socket2.map 'event').to include 'asd'
    end

    it 'feed clients' do
      socket2 = MockSocket.new
      subject.online_event(socket, user, user.token)
      subject.online_event(socket2, user2, user2.token)
      subject.subscribe(socket, [hashtag.id])
      subject.subscribe(socket2, [hashtag.id, hashtag.id + 1])

      subject.broadcast '{ "event": "message" }', hashtag.id

      expect(socket.map 'event').to include 'message'
      expect(socket2.map 'event').to include 'message'
    end
  end

  context 'subscribed' do
    it 'false with no clients' do
      expect(subject.subscribed(user, hashtag.id)).to be false
    end

    it 'false with client not subscribed' do
      subject.online_event(socket, user, user.token)
      expect(subject.subscribed(user, hashtag.id)).to be false
    end

    it 'false with client subscribed other hashtag' do
      subject.online_event(socket, user, user.token)
      subject.subscribe(socket, [hashtag.id + 1])
      expect(subject.subscribed(user, hashtag.id)).to be false
    end

    it 'true with client subscribed to hashtag' do
      subject.online_event(socket, user, user.token)
      subject.subscribe(socket, [hashtag.id])
      expect(subject.subscribed(user, hashtag.id)).to be true
    end
  end

  it 'finds mentions' do
    subject.online_event(socket, user, user.token)
    subject.message_event(socket, user, hashtag, "@#{user.id}")

    expect(socket.map 'event').to include 'mention'
  end
end
