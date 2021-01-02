# frozen_string_literal: true

require 'active_record'
require 'http_logger'
require 'pgq'
require 'active_resource'
require 'active_support/core_ext/string'
require 'active_resource/persistent'
require 'syslog-logger'
require File.expand_path('./support/test_context', __dir__)
require TestContext.root_path.join('lib/json_coder').to_s
require TestContext.root_path.join('lib/json_each_row_coder').to_s
require TestContext.root_path.join('lib/shutdown').to_s
require TestContext.root_path.join('lib/amqp_factory').to_s

require 'webmock/rspec'
require 'bunny-mock'
TestContext.logger.level = Logger::DEBUG

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
