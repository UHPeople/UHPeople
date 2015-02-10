source 'https://rubygems.org'

gem 'rails', '4.2.0'

ruby "2.2.0"

gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'therubyracer', platforms: :ruby

gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'

gem 'rb-readline'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0'
end

gem 'bootstrap-sass'
gem 'faye-websocket'
gem 'puma'

group :development, :test do
  gem 'rspec-rails', '~> 2.14.1'

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  # SQLite database for development and testing
  gem 'sqlite3'
end

group :production do
  # PostgreSQL database for Heroku
  gem 'pg'
  gem 'rails_12factor'
end

group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'launchy'
  gem 'simplecov', require: false
  # gem 'poltergeist'
end

