# frozen_string_literal: true

source 'https://rubygems.org'

# Core
gem 'activemodel-serializers-xml'
gem 'pg'
gem 'postgres_ext', git: 'https://github.com/didww/postgres_ext.git', branch: 'rails-5-2'
gem 'rails', '~> 5.2.3'
gem 'responders'
gem 'secondbase', git: 'https://github.com/yeti-switch/secondbase.git'

# Authentication
gem 'activeldap'
gem 'd3-rails', '3.5.2'
gem 'devise', '>= 4.6.0'
gem 'devise_ldap_authenticatable', git: 'https://github.com/cschiewek/devise_ldap_authenticatable'
gem 'net-ldap', '~> 0.16.0'

# Seamless JWT authentication for Rails API
# need this fix https://github.com/nsarno/knock/pull/126
gem 'knock', git: 'https://github.com/nsarno/knock.git', ref: '66b60437a5acc28e4863f011ab59324dc1b5d0ae'

# ActiveAdmin
gem 'active_admin_date_range_preset', git: 'https://github.com/workgena/active_admin_date_range_preset.git'
gem 'active_admin_datetimepicker'
gem 'active_admin_import', '3.1.0'
gem 'active_admin_scoped_collection_actions'
gem 'active_admin_theme'
gem 'activeadmin'
gem 'draper'
gem 'novus-nvd3-rails', git: 'https://github.com/yeti-switch/nvd3-community-rails.git'
gem 'ransack'

gem 'jrpc', git: 'https://github.com/yeti-switch/jrpc.git', ref: 'ddb9bf3'
gem 'yetis_node', git: 'https://github.com/yeti-switch/yetis_node.git'

gem 'active_admin_sidebar', '1.1.0'

# XLS generation
gem 'excelinator', git: 'https://github.com/livingsocial/excelinator.git'

# REST API
gem 'jsonapi-resources', '0.9.1.beta1'

# gem 'activeadmin_async_export'

# Ext

# Object oriented authorization for Rails applications
gem 'pundit'

gem 'paper_trail'
gem 'parallel'

# Assets
gem 'coffee-rails', '~> 4.0'
gem 'compass-rails', '~> 3.0.2'
gem 'sass-rails'
gem 'sprockets'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'chosen-rails', '1.5.2'
gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'jquery-tablesorter'
gem 'jquery-ui-rails'
gem 'sass-globbing'
gem 'therubyracer', '~> 0.12.1'
gem 'uglifier', '>= 1.3'

# Server Tools
gem 'daemons'
gem 'delayed_job_active_record'
gem 'odf-report', git: 'https://github.com/yeti-switch/odf-report.git', branch: 'master-2018'
gem 'puma'
gem 'puma_worker_killer'
gem 'syslog-logger'
gem 'zip-zip'

group :development do
  gem 'annotate'
  gem 'sourcify'
end

group :development, :test do
  gem 'awesome_print'
  gem 'byebug'
  gem 'thin'

  gem 'bundler-audit', require: false
  gem 'database_cleaner'
  gem 'factory_girl_rails', '4.8.0'
  gem 'rspec-rails'
  gem 'rspec_api_documentation', '~> 5.0.0'
  gem 'rubocop', require: false
  gem 'simplecov', require: false, group: :test
end

gem 'apitome', '~> 0.1.0'

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'chromedriver-helper'
  gem 'cucumber-rails', require: false
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'webmock'
end
gem 'bootsnap', require: false
