source 'https://rubygems.org'

gem 'rails', '4.2.0'

ruby "2.2.0"

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

gem 'rb-readline'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', '~> 0.4.0'
end

# Bootstrap layout
gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem "twitter-bootstrap-rails"



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
  gem 'simplecov', require: false
end

