include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :user do
    name 'asd asd'
    username 'asd'
    email 'asd@asd.fi'
    campus 'Viikki'
    unit 'Maametsis'
    about 'abouttest!!212'
    avatar { fixture_file_upload(Rails.root.join('spec', 'test.png'), 'image/png') }
  end

  factory :hashtag do
    tag 'avantouinti'
  end

  factory :message do
    content 'Hello World!'
  end
end
