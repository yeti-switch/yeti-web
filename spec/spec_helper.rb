# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
if ENV['SKIP_COVERAGE'].nil?
  require 'simplecov'
end

require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'webmock/rspec'
require 'pundit/rspec'
require 'capybara/active_admin/rspec'
WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: 'chromedriver.storage.googleapis.com'
)
# require 'capybara/rspec'

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

include Warden::Test::Helpers
Warden.test_mode!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = Rails.root.join 'spec/fixtures'

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.disable_monkey_patching!

  if Bullet.enable?
    # bullet false positive with HABTM association
    Bullet.add_whitelist type: :n_plus_one_query, class_name: 'Routing::RoutingPlan::HABTM_RoutingGroups', association: :routing_group
    config.before(:each, type: :feature) do
      Bullet.start_request
    end

    config.after(:each, type: :feature) do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end

  config.global_fixtures = [
    'sys.sensor_modes',
    :guiconfig,
    :sortings,
    :destination_rate_policy,
    :session_refresh_methods,
    'sys.sensor_levels',
    :disconnect_policy,
    :disconnect_code_namespace,
    :diversion_policy,
    :filter_types,
    :sdp_c_location,
    :codecs,
    :dump_level,
    :invoice_periods,
    'class4.customers_auth_dst_number_fields',
    'class4.customers_auth_src_number_fields',
    'class4.customers_auth_src_name_fields',
    'class4.dtmf_send_modes',
    'class4.dtmf_receive_modes',
    'class4.gateway_rel100_modes',
    'class4.gateway_inband_dtmf_filtering_modes',
    'class4.gateway_media_encryption_modes',
    'class4.gateway_network_protocol_priorities',
    'class4.transport_protocols',
    'class4.numberlist_modes',
    'class4.numberlist_actions',
    'class4.tag_actions',
    'class4.rate_profit_control_modes',
    'class4.routing_tag_modes',
    'class4.gateway_group_balancing_modes',
    'sys.timezones',
    'sys.jobs',
    'sys.sip_schemas'
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

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.profile_examples = 10
  config.order = :random
  Kernel.srand config.seed

  config.include FactoryBot::Syntax::Methods
  config.include ActiveSupport::Testing::TimeHelpers
  config.include TravelMonotonicHelpers
  config.include RspecRequestHelper, type: :request
  config.include RspecRequestHelper, type: :controller
  config.extend Helpers::ActiveAdminForms::ExampleGroups, type: :feature
  config.include Helpers::ActiveAdminForms::Examples, type: :feature
  config.include FeatureTestHelper, type: :feature
  config.include JRPCMockHelper

  config.around(:each, freeze_time: proc { |val| val == true || val.is_a?(Time) }) do |example|
    val = example.metadata[:freeze_time]
    time = val == true ? Time.now : val
    travel_to(time) { example.run }
  end

  config.around(:each, :sync_delayed_jobs) do |example|
    old_delayed_jobs = Delayed::Worker.delay_jobs
    begin
      Delayed::Worker.delay_jobs = false
      example.run
    ensure
      Delayed::Worker.delay_jobs = old_delayed_jobs
    end
  end

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:suite) do
    # Create partition for current+next monthes if not exists
    Cdr::Cdr.add_partitions
    Cdr::AuthLog.add_partitions
    Cdr::RtpStatistic.add_partitions
    Log::ApiLog.add_partitions
  end

  config.before(:suite) do
    RSpecTestPrometheusClient.instance = RSpecTestPrometheusClient.new
    PrometheusExporter::Client.default = RSpecTestPrometheusClient.instance
  end

  config.before(:each) do
    RSpecTestPrometheusClient.instance.clear!
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
    allow(Raven).to receive(:send_event).with(a_kind_of(Hash))
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

  config.expect_with :rspec do |c|
    #  disable the should syntax...
    c.syntax = :expect
  end
end

RspecApiDocumentation.configure do |config|
  config.format = %i[json html]
  config.request_body_formatter = :json

  config.exclusion_filter = :customer_v1 # important
  config.docs_dir = Rails.root.join 'doc/api/admin'
  config.api_name = 'Admin API'

  config.define_group :customer_v1 do |c|
    c.exclusion_filter = :admin # must be overriden to anything
    c.filter = :customer_v1
    c.docs_dir = Rails.root.join 'doc/api/customer/v1'
    c.api_name = 'Customer API V2'
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec

    with.library :active_record
    with.library :active_model
  end
end
