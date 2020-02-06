# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.5'

gem 'aws-sdk-s3', '~> 1.60.0'
gem 'devise', '~> 4.7.1'
gem 'figaro', '~> 1.1.1'
gem 'pagy', '~> 3.7.1'
gem 'pg', '~> 1.1.4'
gem 'puma', '~> 4.3.1'
gem 'rails', '~> 6.0.2.1'

group :development, :test do
  gem 'database_cleaner', '~> 1.7.0'
  gem 'factory_bot_rails', '~> 5.1.1'
  gem 'faker', '~> 2.9.0'
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rails-controller-testing', '~> 1.0.4'
  gem 'rspec-rails', '~> 3.9.0'
  gem 'shoulda-matchers', '~> 4.1.2'
  gem 'simplecov', require: false
end

group :development do
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'listen'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'spring'
  gem 'spring-watcher-listen'
end
