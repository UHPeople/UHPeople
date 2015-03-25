FactoryGirl.define do
  factory :user do
    name 'asd asd'
    username 'asd'
    email 'asd@asd.fi'
    campus 'Viikki'
    unit 'Maametsis'
    about 'abouttest!!212'
    first_time false
  end

  factory :hashtag do
    tag 'avantouinti'
  end

  factory :message do
    user
    hashtag
    content 'Hello World!'
  end
end
