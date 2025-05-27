# frozen_string_literal: true

Rails.configuration.after_initialize do
  next unless Rails.env.production?
  next if YetiConfig.elasticsearch.blank?

  SemanticLogger.application = 'Yeti'
  transport_options = YetiConfig.elasticsearch.transport_options&.to_h || {}
  SemanticLogger.add_appender(
    appender: :elasticsearch,
    url: YetiConfig.elasticsearch.url,
    batch_size: 10,
    retry_on_failure: true,
    type: nil,
    index: YetiConfig.elasticsearch.index,
    adapter: :net_http,
    transport_options:
  )
end
