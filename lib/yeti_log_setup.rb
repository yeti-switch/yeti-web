# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'semantic_logger'
require_relative 'yeti_config_loader'
require_relative 'yeti_log_component'
require_relative 'yeti_log_formatter'
require_relative 'yeti_plain_log_formatter'

# Registers the SemanticLogger appenders of every yeti-web component, so that they all
# log alike: to stdout, plus elasticsearch when config/yeti_web.yml configures it.
#
# The processes that do not boot Rails - bin/cdr_processor and the standalone
# prometheus_exporter (lib/prometheus_collectors.rb) - get both appenders from .call.
# The Rails processes add them one by one, because the two have to be registered at
# different moments of the boot: stdout from config/application.rb, before the
# initializers run and while the boot itself is still being logged, elasticsearch from
# config/initializers/semantic_logger.rb, that is the first point where YetiConfig is
# loaded. Only the stdout formatter differs between the two, see .add_stdout_appender.
module YetiLogSetup
  module_function

  # Logs to stdout in the plain one line format and to elasticsearch, when it is configured.
  #
  # @param component [String] name of the process, see YetiLogComponent.
  # @param level [String,Symbol] trace, debug, info, warn, error or fatal. Applied to both
  #   appenders unless config/yeti_web.yml gives one of them a level of its own, see
  #   .apply_levels!. Also the level of the boot itself, that is logged before the config
  #   is read.
  # @param tags [Hash] extra static tags of every log record.
  # @return [SemanticLogger::Logger]
  def call(component:, level: :info, tags: {})
    YetiLogComponent.current = component
    SemanticLogger.default_level = level.to_s.downcase.to_sym
    add_stdout_appender(formatter: YetiPlainLogFormatter.new)
    logger = SemanticLogger[component]

    begin
      # elasticsearch is configured in config/yeti_web.yml, that a process may have
      # no other use for. Its absence must not stop the process from working, so it
      # only costs the logging to elasticsearch.
      YetiConfigLoader.call
      apply_levels!(default_level: level, tags:)
    rescue StandardError => e
      # StandardError and not YetiConfigLoader::Error only: an invalid url or transport
      # option makes Elasticsearch::Client.new raise anything from URI::InvalidURIError
      # to Faraday::Error, and none of that may stop the process either.
      logger.warn "Logging to elasticsearch is disabled: #{e.class}: #{e.message}"
    end

    logger
  end

  # The formatter is the only difference between the components: the Rails processes
  # log the `:default` format, that carries the named tags (config.log_tags: request_id,
  # remote_ip) and the durations of the request/SQL records, while the others have
  # neither and use the shorter YetiPlainLogFormatter instead.
  #
  # @param formatter [Symbol, SemanticLogger::Formatters::Base]
  # @param level [String,Symbol,nil] nil follows the global level, see .apply_levels!.
  # @return [SemanticLogger::Subscriber]
  def add_stdout_appender(formatter:, level: nil)
    SemanticLogger.add_appender(io: $stdout, formatter:, level:)
  end

  # The level of each appender separately, from config/yeti_web.yml:
  #
  #   logging:
  #     stdout:
  #       level: 'error'
  #     elasticsearch:
  #       level: 'info'
  #
  # An appender level can only narrow what it is given: a record below the global level
  # is never built at all, so the global level is set to the most verbose of the two.
  # Neither of them configured leaves the global level as the only one, as before.
  #
  # Requires YetiConfig to be loaded.
  #
  # @param default_level [String,Symbol] applied when neither appender has a level of its
  #   own: config.log_level for Rails, the `level` of .call for the other processes.
  # @param tags [Hash] extra static tags, see .add_elasticsearch_appender.
  # @return [SemanticLogger::Subscriber, nil] the elasticsearch appender, nil when it is
  #   not configured.
  def apply_levels!(default_level:, tags: {})
    stdout_level, elasticsearch_level = configured_levels
    SemanticLogger.default_level =
      most_verbose(stdout_level, elasticsearch_level) || default_level.to_s.downcase.to_sym

    SemanticLogger.appenders.each do |appender|
      # The stdout appender is registered elsewhere - by config/application.rb in a Rails
      # process - so it is found rather than passed. AsyncBatch, that wraps the
      # elasticsearch appender, does not respond to #console_output?.
      next unless appender.respond_to?(:console_output?) && appender.console_output?

      # nil restores the appender to following the global level.
      appender.level = stdout_level
    end

    add_elasticsearch_appender(tags:, level: elasticsearch_level)
  end

  # Requires YetiConfig to be loaded.
  #
  # @return [Array(Symbol, Symbol)] the stdout and the elasticsearch level, nil for an
  #   appender that is given none and follows the global level.
  def configured_levels
    logging = YetiConfig.logging
    [logging&.stdout&.level, logging&.elasticsearch&.level].map { |level| level&.to_s&.downcase&.to_sym }
  end

  # SemanticLogger orders its levels from most detailed to most severe (trace..fatal),
  # so the most verbose of a set is the lowest index, not the highest.
  #
  # @param levels [Array<String,Symbol,nil>] nil entries are ignored.
  # @return [Symbol, nil] nil when every level is nil.
  def most_verbose(*levels)
    levels.compact
          .map { |level| level.to_s.downcase.to_sym }
          .min_by { |level| SemanticLogger::Levels.index(level) }
  end

  # Requires YetiConfig to be loaded. Applied in every environment: a blank
  # `logging.elasticsearch.url` is what disables the logging to elasticsearch.
  #
  # @param tags [Hash] extra static tags, added to YetiConfig.logging.elasticsearch.tags.
  # @param level [String,Symbol,nil] nil follows the global level, see .apply_levels!.
  # @return [SemanticLogger::Subscriber, nil] nil when elasticsearch is not configured.
  def add_elasticsearch_appender(tags: {}, level: nil)
    config = YetiConfig.logging&.elasticsearch
    return if config.blank? || config.url.blank?

    # Required here and not at the top of the file: it loads the whole elasticsearch and
    # faraday stack, that bin/cdr_processor has no other use for.
    require_relative 'yeti_elasticsearch_appender'

    static_tags = (config.tags&.to_h || {}).merge(tags)
    # `level` belongs to the appender and not to SemanticLogger.add_appender below:
    # SemanticLogger::Appender.factory returns an already built Subscriber as it is and
    # silently drops every other option given along with it.
    appender = YetiElasticsearchAppender.new(
      url: config.url,
      level:,
      retry_on_failure: true,
      type: nil,
      index: config.index,
      adapter: :net_http,
      transport_options: config.transport_options&.to_h || {},
      formatter: YetiLogFormatter.new(time_format: :iso_8601, time_key: :timestamp, static_tags:)
    )
    SemanticLogger.add_appender(appender:, batch_size: 10)
  end
end
