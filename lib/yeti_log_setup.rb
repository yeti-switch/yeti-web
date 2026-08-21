# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'semantic_logger'
require_relative 'yeti_config_loader'
require_relative 'yeti_log_component'
require_relative 'yeti_log_formatter'
require_relative 'yeti_plain_log_formatter'

# SemanticLogger setup for the processes that do not boot Rails: bin/cdr_processor and
# the standalone prometheus_exporter (lib/prometheus_collectors.rb).
#
# Rails processes are configured by config/environments/*.rb and by
# config/initializers/semantic_logger.rb, that adds the same elasticsearch appender
# through .add_elasticsearch_appender, so that every component logs alike.
module YetiLogSetup
  module_function

  # Logs to stdout in the plain one line format and to elasticsearch, when it is configured.
  #
  # @param component [String] name of the process, see YetiLogComponent.
  # @param level [String,Symbol] trace, debug, info, warn, error or fatal.
  # @param tags [Hash] extra static tags of every log record.
  # @return [SemanticLogger::Logger]
  def call(component:, level: :info, tags: {})
    YetiLogComponent.current = component
    SemanticLogger.default_level = level.to_s.downcase.to_sym
    SemanticLogger.add_appender(io: $stdout, formatter: YetiPlainLogFormatter.new)
    logger = SemanticLogger[component]

    begin
      # elasticsearch is configured in config/yeti_web.yml, that a process may have
      # no other use for. Its absence must not stop the process from working, so it
      # only costs the logging to elasticsearch.
      YetiConfigLoader.call
      add_elasticsearch_appender(tags:)
    rescue StandardError => e
      # StandardError and not YetiConfigLoader::Error only: an invalid url or transport
      # option makes Elasticsearch::Client.new raise anything from URI::InvalidURIError
      # to Faraday::Error, and none of that may stop the process either.
      logger.warn "Logging to elasticsearch is disabled: #{e.class}: #{e.message}"
    end

    logger
  end

  # Requires YetiConfig to be loaded. Applied in every environment: a blank
  # `elasticsearch.url` is what disables the logging to elasticsearch.
  #
  # @param tags [Hash] extra static tags, added to YetiConfig.logs.tags.
  # @return [SemanticLogger::Subscriber, nil] nil when elasticsearch is not configured.
  def add_elasticsearch_appender(tags: {})
    return if YetiConfig.elasticsearch.blank? || YetiConfig.elasticsearch.url.blank?

    # Required here and not at the top of the file: it loads the whole elasticsearch and
    # faraday stack, that bin/cdr_processor has no other use for.
    require_relative 'yeti_elasticsearch_appender'

    static_tags = (YetiConfig.logs&.tags&.to_h || {}).merge(tags)
    appender = YetiElasticsearchAppender.new(
      url: YetiConfig.elasticsearch.url,
      retry_on_failure: true,
      type: nil,
      index: YetiConfig.elasticsearch.index,
      adapter: :net_http,
      transport_options: YetiConfig.elasticsearch.transport_options&.to_h || {},
      formatter: YetiLogFormatter.new(time_format: :iso_8601, time_key: :timestamp, static_tags:)
    )
    SemanticLogger.add_appender(appender:, batch_size: 10)
  end
end
