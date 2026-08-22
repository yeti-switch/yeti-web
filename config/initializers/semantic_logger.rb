# frozen_string_literal: true

# Nothing to configure when the whole semantic logger is skipped, see config/application.rb.
# `yeti_log_setup` is not loaded in that case either: it would require the semantic_logger gem,
# that is `require: false` in the Gemfile.
return if ENV['SKIP_RAILS_SEMANTIC_LOGGER'] == 'true'

require 'yeti_log_setup'
require 'active_job/named_log_tags'

# Applied in every environment but test: an elasticsearch url in config/yeti_web.yml is
# what enables it, not the environment the application runs in. The test suite is excluded
# because config/yeti_web.yml is not environment scoped: a production config copied to a
# developer machine would make every `rspec` run ship records to the production storage.
Rails.configuration.after_initialize do
  next if Rails.env.test?

  YetiLogSetup.add_elasticsearch_appender
end
