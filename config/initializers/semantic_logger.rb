# frozen_string_literal: true

require 'yeti_log_setup'

Rails.configuration.after_initialize do
  next unless Rails.env.production?

  YetiLogSetup.add_elasticsearch_appender
end
