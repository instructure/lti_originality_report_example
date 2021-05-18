# frozen_string_literal: true

ruby '2.4.1'
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

source 'https://rails-assets.org' do
  gem 'rails-assets-tether', '>= 1.3.3'
end

gem 'bootstrap', '~> 4.3.1'
gem 'httparty'
gem 'ims-lti', git: 'https://github.com/instructure/ims-lti.git', branch: 'ws_security'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails'
gem 'json-jwt'
gem 'mini_racer', '~> 0.2.6'
gem 'pg', '~> 0.18'
gem 'puma', '~> 4.3'
gem 'rack-timeout', '~> 0.4'
gem 'rails', '~> 5'
gem 'redis-rails', '~> 5'
gem 'sass-rails', ' ~> 5'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails', '~> 3.5'
  gem 'rubocop', require: false
  gem 'sqlite3'
end

group :test do
  gem 'database_cleaner'
end

group :development do
  gem 'listen', '~> 3.0.5'
  gem 'rack-mini-profiler', '~> 0.10'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '~> 3.3.0'
end
gem 'tzinfo-data', platforms: %i(mingw mswin x64_mingw jruby)
