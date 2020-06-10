# frozen_string_literal: true

source 'https://rubygems.org'

# Core
gem 'active_record_extended'
gem 'activemodel-serializers-xml'
gem 'pg'
gem 'rack', '2.1.3' # https://github.com/rack/rack/issues/1628
gem 'rails', '~> 5.2.4'
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
gem 'active_admin_import'
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
gem 'puma', '~> 4.3'
gem 'puma_worker_killer'
gem 'syslog-logger'
gem 'zip-zip'

gem 'pgq_prometheus', require: false
gem 'prometheus_exporter', git: 'https://github.com/didww/prometheus_exporter.git', branch: 'didww', require: false
gem 'sentry-raven', require: false

group :development do
  gem 'annotate'
  gem 'sourcify'
end

group :development, :test do
  gem 'awesome_print'
  gem 'bullet'
  gem 'byebug'
  gem 'thin'

  gem 'bundler-audit', require: false
  gem 'database_cleaner'
  gem 'factory_bot_rails'
  gem 'parallel_tests'
  gem 'rspec-rails'
  gem 'rspec_api_documentation', '~> 5.0.0'
  gem 'rubocop', require: false
end

gem 'apitome', '~> 0.1.0'

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'coveralls', require: false
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'webdrivers', '~> 4.0'
  gem 'webmock'
end
gem 'bootsnap', require: false
