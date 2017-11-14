source 'https://rubygems.org'

# Core
gem 'pg'
gem 'rails', '~> 4.2.9'
gem 'responders', '~> 2.2.0'
gem 'activerecord-postgres-dump-schemas' # TODO: deprecated for Rails 5
gem 'secondbase', git: 'https://github.com/yeti-switch/secondbase.git'

# Authentication
gem 'devise', '~> 3.5.10'
gem 'devise_ldap_authenticatable', '~> 0.8', github: 'yeti-switch/devise_ldap_authenticatable'
gem 'activeldap'
gem 'net-ldap', '~> 0.3.1'
gem 'd3-rails'

# Seamless JWT authentication for Rails API
# need this fix https://github.com/nsarno/knock/pull/126
gem 'knock', git: 'https://github.com/nsarno/knock.git', ref: '66b60437a5acc28e4863f011ab59324dc1b5d0ae'

# ActiveAdmin
gem 'ransack', '~> 1.4.0'
gem 'draper', '~>  2.1.0'
gem 'activeadmin', github: 'yeti-switch/active_admin'
gem 'novus-nvd3-rails', github: 'yeti-switch/nvd3-community-rails'
gem 'active_admin_theme'
gem 'active_admin_import' , '3.0.0.pre'
gem 'active_admin_scoped_collection_actions', github: 'Zamyatin-AA/active_admin_scoped_collection_actions', branch: 'batch_action_collection_fix'
gem 'active_admin_datetimepicker', github: 'activeadmin-plugins/activeadmin_datetimepicker'
gem 'active_admin_date_range_preset', github: 'workgena/active_admin_date_range_preset'

gem 'yetis_node', github: 'yeti-switch/yetis_node'
gem 'active_admin_sidebar', github: 'activeadmin-plugins/active_admin_sidebar'

# XLS generation
gem 'excelinator', github: 'livingsocial/excelinator'

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
#gem 'odf-report', github: 'sandrods/odf-report'
gem 'odf-report', github: 'yeti-switch/odf-report'
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
  gem 'byebug'

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
  gem 'cucumber-rails', :require => false
  gem 'faker'
  gem 'poltergeist'
end
