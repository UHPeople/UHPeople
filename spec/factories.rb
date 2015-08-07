include ActionDispatch::TestProcess

FactoryGirl.define do
  factory :user do
    name 'asd asd'
    username 'asd'
    email 'asd@asd.fi'
    campus 'Viikki'
    about 'abouttest!!212'
    first_time false
  end

  factory :hashtag do
    tag 'avantouinti'
  end

  factory :message do
    content 'Hello World! @asd #avantouinti'
  end

  factory :photo do
    image { fixture_file_upload(Rails.root.join('spec', 'test.png'), 'image/png') }
  end
end
