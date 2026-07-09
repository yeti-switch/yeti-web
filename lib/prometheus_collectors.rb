# frozen_string_literal: true

# Custom prometheus type collectors should be defined as lib/prometheus/*_collector.rb files.

# Disabling buffering for stdout and stderr
$stderr.sync = true
$stdout.sync = true

require 'active_support/all'

# This process does not boot Rails, so YetiConfig has to be loaded explicitly.
# Collectors that seed their counters with zero values read prometheus.default_labels from it.
require_relative 'yeti_config_loader'
YetiConfigLoader.call

Dir[File.join(__dir__, 'prometheus/*_collector.rb')].each do |filename|
  require_relative filename
end

require 'pgq_prometheus'
require 'pgq_prometheus/collector'
require_relative 'prometheus/pgq_prometheus_config'
