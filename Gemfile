source 'https://rubygems.org'
ruby '2.2.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2'
# Use postgresql as the database for Active Record
gem 'pg', '~> 0.15'
# Use SCSS for stylesheets
# gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
# gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
# gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
gem 'thin', require: false
gem 'kaminari'
gem 'jwt'
gem 'faye-rails'
gem 'rails-api'
gem 'nokogiri', '>= 1.6.7.2'
gem 'sidekiq'
gem 'faye-redis'
gem 'rubocop', require: false
gem 'activerecord', '~> 4.2', '>= 4.2.5.1'
gem 'actionpack', '~> 4.2', '>= 4.2.5.2'
gem 'activemodel', '~> 4.2', '>= 4.2.5.2'
gem 'actionview', '~> 4.2', '>= 4.2.5.2'
gem 'annotate'
gem 'redis-rails'
gem 'redis'
gem 'hiredis'
gem 'redis-namespace'

group :test do
  gem 'shoulda-matchers'
  gem 'simplecov', require: false
  gem 'rspec-prof', git: 'https://github.com/sinisterchipmunk/rspec-prof.git'
  gem 'codeclimate-test-reporter', require: false
end

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'faker'
  gem 'rspec-rails'
  gem 'factory_girl_rails'
  gem 'pry-rails'
  gem 'email_spec'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'rails-erd'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
