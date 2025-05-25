# frozen_string_literal: true

require 'semantic_logger'

APP_NAME = 'yeti-web'

Rails.configuration.after_initialize do
  # one of the adapters that use semantic_logger is set in the config
  if [ApiLogger::CONST::ELASTICSEARCH_ADAPTER, ApiLogger::CONST::VICTORIALOGS_ADAPTER].include?(ApiLogger.adapter)

    SemanticLogger.default_level = :debug

    formatter = if ApiLogger.adapter == ApiLogger::CONST::VICTORIALOGS_ADAPTER
                  SemanticLogger::VictoriaLogsFormatter.new
                else
                  SemanticLogger::Formatters::Raw.new
                end

    SemanticLogger.add_appender(
      appender: :elasticsearch,
      url: YetiConfig.api_logs.url,
      batch_size: 10,
      retry_on_failure: true,
      type: nil,
      index: YetiConfig.api_logs.index,
      adapter: :net_http,
      formatter:
    )
  end
  SemanticLogger.application = APP_NAME
end
