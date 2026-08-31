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

  # Top level keys of the logging configuration that preceded the `logging` block, see
  # YetiLogSetup. Rejected explicitly because nothing else would: YetiConfigSchema cannot
  # turn on the `validate_keys` of dry-schema - it has no way to allow the user defined
  # keys of `logging.elasticsearch.tags` and of the other free form blocks, see
  # https://github.com/dry-rb/dry-schema/issues/37 - so an unknown key is simply ignored.
  # A configuration still using these would load, and then silently stop shipping the
  # logs to elasticsearch, with nothing pointing at the renamed key.
  LEGACY_KEYS = %i[logs elasticsearch].freeze

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
