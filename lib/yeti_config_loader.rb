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

  # Renamed into the `logging` block, see YetiLogSetup. Rejected explicitly because
  # nothing else would: the `validate_keys` of dry-schema cannot be turned on while the
  # config has free form blocks (dry-rb/dry-schema#37), so an unknown key is ignored and
  # an outdated config would load and silently stop shipping the logs.
  LEGACY_KEYS = %i[logs elasticsearch].freeze

  module_function

  # @param path [String]
  # @raise [YetiConfigLoader::Error] when the file is missing or does not satisfy YetiConfigSchema
  def call(path = CONFIG_PATH)
    # Already loaded - but still validated: load_and_set_settings defines the settings
    # before the legacy keys can be rejected, so a caller that rescued the error left a
    # loaded YetiConfig behind (YetiLogSetup.preloaded_stdout_level does), and returning
    # here would hide the outdated config from the caller that reports it.
    return reject_legacy_keys!(path) if defined?(::YetiConfig)

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
    reject_legacy_keys!(path)
    nil
  rescue Config::Validation::Error => e
    raise Error, "invalid config #{path}: #{e.message}"
  end

  # @param path [String]
  # @raise [YetiConfigLoader::Error] when the configuration still uses a renamed key.
  def reject_legacy_keys!(path)
    keys = ::YetiConfig.to_h.keys
    outdated = LEGACY_KEYS & keys
    return if outdated.empty?

    raise Error, "outdated config #{path}: #{outdated.join(', ')} moved under `logging`, " \
                 'see the logging block of config/yeti_web.yml.distr'
  end
end
