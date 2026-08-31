# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'semantic_logger'
require_relative 'yeti_config_loader'
require_relative 'yeti_log_component'
require_relative 'yeti_log_formatter'
require_relative 'yeti_plain_log_formatter'

# Registers the SemanticLogger appenders of every yeti-web component: stdout, plus
# elasticsearch when config/yeti_web.yml configures it.
#
# The processes that do not boot Rails - bin/cdr_processor and the standalone
# prometheus_exporter - get both from .call. A Rails process registers them separately:
# stdout from config/application.rb, so that the boot is logged too, elasticsearch from
# config/initializers/semantic_logger.rb, the first point where YetiConfig is loaded.
module YetiLogSetup
  # Applied when `logging.elasticsearch.batch_size` is not configured, see .batch_options.
  DEFAULT_BATCH_SIZE = 10

  # A full queue drops the records rather than blocking the thread that called the logger.
  # Not configurable: a request must never wait on the log storage.
  NON_BLOCKING = true
  DROPPED_MESSAGE_REPORT_SECONDS = 30

  module_function

  # Logs to stdout in the plain one line format and to elasticsearch, when it is configured.
  #
  # @param component [String] name of the process, see YetiLogComponent.
  # @param level [String,Symbol] the fallback of .apply_levels!, and the level of the boot
  #   itself, that is logged before the config is read.
  # @param tags [Hash] extra static tags of every log record.
  # @return [SemanticLogger::Logger]
  def call(component:, level: :info, tags: {})
    YetiLogComponent.current = component
    SemanticLogger.default_level = level.to_s.downcase.to_sym
    add_stdout_appender(formatter: YetiPlainLogFormatter.new)
    logger = SemanticLogger[component]

    begin
      YetiConfigLoader.call
      apply_levels!(default_level: level, tags:)
    rescue StandardError => e
      # A process may have no other use for config/yeti_web.yml, and an invalid url or
      # transport option makes Elasticsearch::Client.new raise anything from
      # URI::InvalidURIError to Faraday::Error. None of that may stop the process.
      logger.warn "Logging to elasticsearch is disabled: #{e.class}: #{e.message}"
    end

    logger
  end

  # Arguments of SemanticLogger.add_appender. Returned rather than applied, because a
  # Rails process declares the appender through config.rails_semantic_logger.appenders
  # and the gem adds it while building the logger.
  #
  # @param formatter [Symbol, SemanticLogger::Formatters::Base] `:default` for the Rails
  #   processes, that have named tags and durations to show, see YetiPlainLogFormatter.
  # @param level [String,Symbol,nil] nil follows the global level.
  # @return [Hash]
  def stdout_appender_options(formatter:, level: nil)
    { io: $stdout, formatter:, level: }
  end

  # @return [SemanticLogger::Subscriber] see .stdout_appender_options.
  def add_stdout_appender(formatter:, level: nil)
    SemanticLogger.add_appender(**stdout_appender_options(formatter:, level:))
  end

  # Applies `logging.stdout.level` and `logging.elasticsearch.level`. An appender level
  # can only narrow what it is given - a record below the global level is never built at
  # all - so the global level becomes the most verbose of the two.
  #
  # Requires YetiConfig to be loaded.
  #
  # @param default_level [String,Symbol] config.log_level for Rails, the `level` of .call
  #   for the other processes.
  # @param tags [Hash] extra static tags, see .add_elasticsearch_appender.
  # @return [SemanticLogger::Subscriber, nil] the elasticsearch appender.
  def apply_levels!(default_level:, tags: {})
    stdout_level, elasticsearch_level = configured_levels
    fallback = default_level.to_s.downcase.to_sym

    if stdout_level.nil? && elasticsearch_level.nil?
      SemanticLogger.default_level = fallback
    else
      # The unconfigured appender is pinned to the fallback rather than left following the
      # global level: that level is about to be lowered for the other one, and following
      # it would hand this one the other's records.
      stdout_level ||= fallback
      elasticsearch_level ||= fallback
      SemanticLogger.default_level = most_verbose(stdout_level, elasticsearch_level)
    end

    # Found and not passed: config/application.rb registers the stdout appender. The Async
    # proxy of the elasticsearch appender delegates #console_output? to it, and it is false.
    SemanticLogger.appenders.each do |appender|
      next unless appender.respond_to?(:console_output?) && appender.console_output?

      appender.level = stdout_level
    end

    add_elasticsearch_appender(tags:, level: elasticsearch_level)
  end

  # Loads the config itself: config/application.rb declares the appender before the
  # initializers run, and .apply_levels! would only level it hundreds of records later.
  #
  # @return [Symbol, nil] nil when no level is configured, and when the config cannot be
  #   read - config/initializers/config.rb reports that properly a moment later.
  def preloaded_stdout_level
    YetiConfigLoader.call
    configured_levels.first
  rescue StandardError
    nil
  end

  # Requires YetiConfig to be loaded.
  #
  # @return [Array<Symbol, nil>] two elements, the stdout and the elasticsearch level,
  #   nil for an appender that is given none of its own.
  def configured_levels
    logging = YetiConfig.logging
    [logging&.stdout&.level, logging&.elasticsearch&.level].map { |level| level&.to_s&.downcase&.to_sym }
  end

  # SemanticLogger orders trace..fatal, so the most verbose is the lowest index.
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
  # @return [SemanticLogger::Appender::Async, nil] the proxy that queues the records, not
  #   the YetiElasticsearchAppender that writes them. nil when it is not configured.
  def add_elasticsearch_appender(tags: {}, level: nil)
    config = YetiConfig.logging&.elasticsearch
    return if config.blank? || config.url.blank?

    # Not at the top of the file: it loads the whole elasticsearch and faraday stack,
    # that bin/cdr_processor has no other use for.
    require_relative 'yeti_elasticsearch_appender'

    static_tags = (config.tags&.to_h || {}).merge(tags)
    # `level` goes to the appender and not to add_appender below: Appender.factory returns
    # an already built Subscriber as it is, silently dropping the options beside it.
    appender = YetiElasticsearchAppender.new(
      url: config.url,
      level:,
      retry_on_failure: true,
      index: config.index,
      adapter: :net_http,
      transport_options: config.transport_options&.to_h || {},
      formatter: YetiLogFormatter.new(time_format: :iso_8601, time_key: :timestamp, static_tags:)
    )
    SemanticLogger.add_appender(appender:, **batch_options(config))
  end

  # Options of SemanticLogger::Appender::Async, that batches the records in its own
  # thread. An unconfigured one is left out, so that the default of the gem applies -
  # except batch_size, whose default of 300 is a lot to lose to a restart at our log rate.
  #
  # @param config [Config::Options] YetiConfig.logging.elasticsearch
  # @return [Hash]
  def batch_options(config)
    {
      batch_size: config.batch_size || DEFAULT_BATCH_SIZE,
      batch_seconds: config.batch_seconds,
      max_queue_size: config.max_queue_size
    }.compact.merge(
      non_blocking: NON_BLOCKING,
      dropped_message_report_seconds: DROPPED_MESSAGE_REPORT_SECONDS
    )
  end
end
