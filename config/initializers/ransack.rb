# frozen_string_literal: true

Ransack.configure do |config|
  config.ignore_unknown_conditions = false
  config.sanitize_custom_scope_booleans = false
end
