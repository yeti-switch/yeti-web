# frozen_string_literal: true

source 'https://rubygems.org'

# Core
gem 'activemodel-serializers-xml'
gem 'active_record_extended'
gem 'activerecord-import'
gem 'pg'
gem 'pg_advisory_lock', git: 'https://github.com/didww/pg_advisory_lock.git'
gem 'pg_sql_caller', git: 'https://github.com/didww/pg_sql_caller.git'
gem 'rack'
gem 'rails', '~> 7.2.0'
gem 'responders'

# Authentication
gem 'activeldap'
gem 'd3-rails', '3.5.2'
gem 'devise', '>= 4.6.0'
gem 'devise_ldap_authenticatable', github: 'cschiewek/devise_ldap_authenticatable', branch: 'default'
gem 'net-ldap', '~> 0.19.0'
gem 'ostruct', '~> 0.6.1' # need for net-ldap

# Seamless JWT authentication for Rails API
gem 'jwt'

# ActiveAdmin
gem 'activeadmin'
gem 'active_admin_date_range_preset', github: 'workgena/active_admin_date_range_preset'
gem 'active_admin_datetimepicker'
gem 'active_admin_import'
gem 'active_admin_scoped_collection_actions'
gem 'active_admin_theme'
gem 'draper'
gem 'novus-nvd3-rails', github: 'yeti-switch/nvd3-community-rails'
gem 'ransack'

gem 'jrpc', github: 'didww/jrpc'

gem 'active_admin_sidebar', '1.1.0'

# XLS generation
# can be switched back to the original repo after ruby 3 fix PR merged
# https://github.com/livingsocial/excelinator/pull/19
gem 'excelinator', github: 'senid231/excelinator', branch: 'ruby3-fix'

# REST API
# TODO: switch to the official gem from rubygems.org after the 0.9.13 release
# https://github.com/cerebris/jsonapi-resources/issues/1456#issuecomment-2710742154
# https://github.com/cerebris/jsonapi-resources/pull/1463
gem 'jsonapi-resources', github: 'cerebris/jsonapi-resources', branch: 'release-0-9'

# gem 'activeadmin_async_export'

# Ext
gem 'validates_timeliness', '~> 7.0.0.beta1'

# Object-oriented authorization for Rails applications
gem 'pundit'

gem 'paper_trail'
gem 'parallel'

# Assets
gem 'sass-rails'
gem 'sprockets'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'chosen-rails', '1.5.2', require: 'chosen-rails/engine'
gem 'font-awesome-rails'
gem 'jquery-rails'
gem 'jquery-tablesorter'
gem 'jquery-ui-rails', github: 'jquery-ui-rails/jquery-ui-rails', tag: 'v7.0.0'
gem 'mini_racer'
gem 'rails-html-sanitizer', '>= 1.6.1'
gem 'uglifier', '>= 1.3'

# Server Tools
gem 'daemons'
gem 'delayed_job_active_record'
gem 'odf-report', github: 'yeti-switch/odf-report', branch: 'master-2018'
gem 'puma', '~> 6.1'
gem 'puma_worker_killer'
gem 'syslog', '~> 0.2.0' # need for syslog-logger
gem 'syslog-logger'
gem 'zip-zip'

gem 'pgq_prometheus', require: false
gem 'prometheus_exporter', github: 'didww/prometheus_exporter', branch: 'didww', require: false
gem 'sentry-delayed_job', require: false
gem 'sentry-rails', require: false
gem 'sentry-ruby', require: false

gem 'rufus-scheduler', require: false

# Easiest way to add multi-environment yaml settings to Rails, Sinatra, Pandrino and other Ruby projects.
# https://github.com/rubyconfig/config
gem 'config', require: false
gem 'dry-validation', '~> 1.0', require: false

group :development do
  gem 'annotate'
  gem 'listen', require: false
end

group :development, :test do
  gem 'awesome_print'
  gem 'bullet'
  gem 'byebug'

  gem 'brakeman'
  gem 'bundler-audit', require: false
  gem 'factory_bot_rails'
  gem 'parallel_tests'
  gem 'rspec_api_documentation', github: 'stitchfix/rspec_api_documentation'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
end

group :test do
  gem 'capybara'
  gem 'capybara_active_admin', github: 'activeadmin-plugins/capybara_active_admin', require: false
  gem 'capybara-screenshot'
  gem 'cuprite'
  gem 'database_consistency', require: false
  gem 'ferrum'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers'
  gem 'simplecov', '~> 0.21.2', require: false
  gem 'simplecov-cobertura', '~> 2.1', require: false
  gem 'webdrivers', '~> 4.0'
  gem 'webmock'
end
gem 'bootsnap', require: false

gem 'httparty', '~> 0.21.0'

gem 'matrix', '~> 0.4.2'

gem 'net-smtp', '~> 0.3.3'

gem 'webrick', '~> 1.8', require: false

gem 'cronex', '~> 0.12.0'

gem 'click_house'

gem 'aws-sdk-s3', require: false
gem 'cryptomus', '~> 0.2.2'
gem 'elasticsearch', require: false
gem 'opentelemetry-exporter-otlp'
gem 'opentelemetry-instrumentation-all'
gem 'opentelemetry-sdk'
gem 'rails_semantic_logger', require: false
