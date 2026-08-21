# frozen_string_literal: true

# Nothing to configure when the whole semantic logger is skipped, see config/application.rb.
# `yeti_log_setup` is not loaded in that case either: it would require the semantic_logger gem,
# that is `require: false` in the Gemfile.
return if ENV['SKIP_RAILS_SEMANTIC_LOGGER'] == 'true'

require 'yeti_log_setup'

# Applied in every environment: an elasticsearch url in config/yeti_web.yml is what
# enables it, not the environment the application runs in.
Rails.configuration.after_initialize do
  YetiLogSetup.add_elasticsearch_appender
end
