# frozen_string_literal: true

# Custom prometheus type collectors should be defined as lib/prometheus/*_collector.rb files.

# Disabling buffering for stdout and stderr
$stderr.sync = true
$stdout.sync = true

require 'active_support/all'

Dir[File.join(__dir__, 'prometheus/*_collector.rb')].each do |filename|
  require_relative filename
end

require 'pgq_prometheus'
require 'pgq_prometheus/collector'
require_relative 'prometheus/pgq_prometheus_config'
