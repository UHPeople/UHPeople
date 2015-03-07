require 'rails_helper'
require_relative '../../lib/chat_backend'

describe ChatBackend do
  class MockSocket
    def initialize
      @sent = []
    end

    def send(data)
      @sent << JSON.parse(data)
    end

    attr_reader :sent
  end

  let!(:user) { FactoryGirl.create(:user) }
  let!(:hashtag) { FactoryGirl.create(:hashtag) }

  let!(:socket) { MockSocket.new }

  let!(:app) { -> { [200, { 'Content-Type' => 'text/plain' }, ['OK']] } }
  subject { UHPeople::ChatBackend.new app  }

  it 'sanitizes messages' do
    message = { 'event': 'message', 'content': '<h1>asd</h1>', 'user': user.id, 'hashtag': hashtag.id }

    sanitized_json = subject.sanitize message
    sanitized = JSON.parse sanitized_json

    expect(sanitized['content']).to eq '&lt;h1&gt;asd&lt;/h1&gt;'
  end

  it 'responds with error to invalid user' do
    message = { 'event': 'online', 'user': -1, 'hashtag': hashtag.id }
    subject.respond(socket, message)

    expect(socket.sent.last['event']).to eq 'error'
    expect(socket.sent.last['content']).to eq 'Invalid user id'
  end

  # it 'responds with error to invalid hashtag' do
  #  message = { 'event': 'online', 'user': user.id, 'hashtag': -1 }
  #  subject.respond(socket, message)
  #  expect(socket.sent.last['event']).to eq 'error'
  #  expect(socket.sent.last['content']).to eq 'Invalid hashtag id'
  # end

  it 'removes online users' do
    message = { 'event': 'online', 'user': user.id, 'hashtag': hashtag.id }
    subject.respond(socket, message)

    subject.remove_online_user socket

    onlines_json = subject.online_users
    onlines = JSON.parse(onlines_json)

    expect(onlines['event']).to eq 'online'
    expect(onlines['onlines'].count).to eq 0
  end

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
end
