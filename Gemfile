source 'https://rubygems.org'

# Core
gem 'pg'
gem 'rails', '~> 4.2.9'
gem 'responders', '~> 2.2.0'
gem 'activerecord-postgres-dump-schemas' # TODO: deprecated for Rails 5
gem 'secondbase', git: 'https://github.com/yeti-switch/secondbase.git'

# Authentication
gem 'devise', '~> 3.5.10'
gem 'devise_ldap_authenticatable', '~> 0.8', git: 'https://github.com/yeti-switch/devise_ldap_authenticatable.git'
gem 'activeldap'
gem 'net-ldap', '~> 0.3.1'
gem 'd3-rails'

# Seamless JWT authentication for Rails API
# need this fix https://github.com/nsarno/knock/pull/126
gem 'knock', git: 'https://github.com/nsarno/knock.git', ref: '66b60437a5acc28e4863f011ab59324dc1b5d0ae'

# ActiveAdmin
gem 'ransack', '~> 1.4.0'
gem 'draper', '~>  2.1.0'
gem 'activeadmin', git: 'https://github.com/yeti-switch/active_admin.git'
gem 'novus-nvd3-rails', git: 'https://github.com/yeti-switch/nvd3-community-rails.git'
gem 'active_admin_theme'
gem 'active_admin_import' , '3.0.0.pre'
gem 'active_admin_scoped_collection_actions'
gem 'active_admin_datetimepicker', git: 'https://github.com/activeadmin-plugins/activeadmin_datetimepicker.git', ref: '16f2d40484172a5fdb0a4a7c0a12add51a762bd0'
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
gem 'paper_trail', '~> 3.0.6'
gem 'parallel'


# Assets
gem 'sass-rails', '~> 4.0.0'
gem 'sprockets', '2.11.0'
gem 'coffee-rails', '~> 4.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer', '~> 0.12.1'
gem 'uglifier', '>= 1.3'
gem 'jquery-rails', '3.1.2'
gem 'jquery-ui-rails', '5.0.3'
gem 'chosen-rails', '1.3.0'
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
  gem 'quiet_assets'
end

#group :development do
  gem 'sourcify'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'annotate'
#end

group :development, :test do
  gem 'byebug'
  gem 'thin'

  gem 'rspec-rails', '~> 3.4.2'
  gem 'factory_girl_rails'
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
  gem 'shoulda-matchers'
end
