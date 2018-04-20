source 'https://rubygems.org'

# Core
gem 'activemodel-serializers-xml'
gem 'pg'
gem 'postgres_ext', git: 'https://github.com/didww/postgres_ext.git', branch: 'rails-5'
gem 'rails', '~> 5.0.0'
gem 'responders', '~> 2.2.0'
gem 'secondbase', git: 'https://github.com/yeti-switch/secondbase.git'

# Authentication
gem 'devise'
gem 'devise_ldap_authenticatable', git: 'https://github.com/cschiewek/devise_ldap_authenticatable'
gem 'activeldap'
gem 'net-ldap', '~> 0.16.0'
gem 'd3-rails'

# Seamless JWT authentication for Rails API
# need this fix https://github.com/nsarno/knock/pull/126
gem 'knock', git: 'https://github.com/nsarno/knock.git', ref: '66b60437a5acc28e4863f011ab59324dc1b5d0ae'

# ActiveAdmin
gem 'ransack'
gem 'draper'
gem 'activeadmin', '~> 1.0.0'
gem 'novus-nvd3-rails', git: 'https://github.com/yeti-switch/nvd3-community-rails.git'
gem 'active_admin_theme'
gem 'active_admin_import', '3.1.0'
gem 'active_admin_scoped_collection_actions'
# latest version compatible with current(old) ActiveAdmin
gem 'active_admin_datetimepicker', '0.5.0'
gem 'active_admin_date_range_preset', git: 'https://github.com/workgena/active_admin_date_range_preset.git'

gem 'yetis_node', git: 'https://github.com/yeti-switch/yetis_node.git'
gem 'jrpc', git: 'https://github.com/yeti-switch/jrpc.git', ref: 'ddb9bf3'

gem 'active_admin_sidebar', git: 'https://github.com/activeadmin-plugins/active_admin_sidebar.git'

# XLS generation
gem 'excelinator', git: 'https://github.com/livingsocial/excelinator.git'

# REST API
gem 'jsonapi-resources', '~> 0.9.1.beta1'

# gem 'activeadmin_async_export'

# Ext

gem 'cancan', '1.6.10'
gem 'paper_trail'
gem 'parallel'


# Assets
gem 'compass-rails', '~> 3.0.2'
gem 'sass-rails'
gem 'sprockets'
gem 'coffee-rails', '~> 4.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', '~> 0.12.1'
gem 'uglifier', '>= 1.3'
gem 'jquery-rails'
gem 'jquery-ui-rails', '5.0.3'
gem 'chosen-rails'
gem 'jquery-tablesorter'
gem 'font-awesome-rails'
gem 'sass-globbing'

# Server Tools
gem 'delayed_job_active_record'
gem 'daemons'
gem 'unicorn'
gem 'syslog-logger'
gem 'odf-report', git: 'https://github.com/yeti-switch/odf-report.git', branch: 'master-2018'
gem 'zip-zip'

group :development do
  gem 'sourcify'
  gem 'annotate'
end

group :development, :test do
  gem 'byebug'
  gem 'awesome_print'
  gem 'thin'

  gem 'rspec-rails'
  gem 'factory_girl_rails', '4.8.0'
  gem 'database_cleaner'
  gem 'selenium-webdriver', '~> 2.53'
  gem 'rspec_api_documentation', '~> 5.0.0'
end

gem 'unicorn-worker-killer'
gem 'apitome', '~> 0.1.0'

group :test do
  gem 'capybara'
  gem 'capybara-screenshot'
  gem 'cucumber-rails', require: false
  gem 'poltergeist'
  gem 'phantomjs', require: 'phantomjs/poltergeist'
  gem 'shoulda-matchers'
  gem 'webmock'
end
