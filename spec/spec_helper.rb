# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)
# require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.global_fixtures = [
      :pops,
      :nodes,
      'sys.sensor_modes',
      :guiconfig,
      :sortings,
      :destination_rate_policy,
      :session_refresh_methods,
      'sys.sensor_levels',
      :disconnect_policy,
      :diversion_policy,
      :filter_types,
      :sdp_c_location,
      :codecs,
      :dump_level,
      'class4.dtmf_send_modes',
      'class4.dtmf_receive_modes',
      'class4.gateway_rel100_modes',
      'class4.gateway_inband_dtmf_filtering_modes',
      'class4.transport_protocols',
      'class4.numberlist_modes',
      'class4.numberlist_actions',
      'class4.tag_actions',
      'class4.rate_profit_control_modes',
      'class4.routing_tag_modes',
      'sys.timezones'
  ]

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  config.include FactoryGirl::Syntax::Methods

  config.before(:suite) do
    DatabaseCleaner.clean_with :truncation
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, js: true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

RspecApiDocumentation.configure do |config|
  config.format = [:json, :html]
  config.request_body_formatter = :json

  config.exclusion_filter = :customer_v1 # important
  config.docs_dir = Rails.root.join("doc", "api", "admin")
  config.api_name = "Admin API"

  config.define_group :customer_v1 do |c|
    c.exclusion_filter = :admin # must be overriden to anything
    c.filter = :customer_v1
    c.docs_dir = Rails.root.join("doc", "api", "customer", 'v1')
    c.api_name = "Customer API V2"
  end
end


Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec

    with.library :active_record
    with.library :active_model
  end
end
