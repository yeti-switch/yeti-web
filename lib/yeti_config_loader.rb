# frozen_string_literal: true

require 'config'
require_relative 'yeti_config_schema'

# Loads config/yeti_web.yml into YetiConfig. Used both by the Rails application
# (config/initializers/config.rb) and by processes that never boot Rails, such as the standalone
# prometheus_exporter (lib/prometheus_collectors.rb), so that every reader of YetiConfig gets the
# same file validated against the same schema.
module YetiConfigLoader
  class Error < StandardError; end

  CONFIG_PATH = File.expand_path('../config/yeti_web.yml', __dir__)

  module_function

  # @param path [String]
  # @raise [YetiConfigLoader::Error] when the file is missing or does not satisfy YetiConfigSchema
  def call(path = CONFIG_PATH)
    return if defined?(::YetiConfig)

    # Config.load_and_set_settings accepts a missing path and defines an empty YetiConfig, so the
    # absence has to be caught here. Checked before Config.setup to leave no global config applied.
    raise Error, "config file not found: #{path}" unless File.exist?(path)

    Config.setup do |config|
      config.const_name = 'YetiConfig'
      config.use_env = false
      YetiConfigSchema.apply(config)
    end
    Config.evaluate_erb_in_yaml = true
    Config.load_and_set_settings(path)
    nil
  rescue Config::Validation::Error => e
    raise Error, "invalid config #{path}: #{e.message}"
  end

  # probes.ready_require_databases against the names of database.yml. Not part of
  # YetiConfigSchema: that is applied by processes that never read database.yml.
  #
  # @param database_names [Array<String>]
  # @raise [YetiConfigLoader::Error]
  def check_databases!(database_names)
    unknown = Array(YetiConfig.probes&.ready_require_databases).map(&:to_s) - database_names.map(&:to_s)
    return if unknown.empty?

    raise Error, "invalid config probes.ready_require_databases: unknown #{unknown.join(', ')}, " \
                 "database.yml has #{database_names.join(', ')}"
  end
end
