# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

session_options = {
  key: '_yeti_session'
}

# Configure session expiration if admin_ui.session_lifetime is set
# Note: Config is loaded in config/initializers/config.rb which runs before this file
if defined?(YetiConfig) && YetiConfig.admin_ui&.session_lifetime.present?
  session_options[:expire_after] = YetiConfig.admin_ui.session_lifetime.seconds
end

Rails.application.config.session_store :cookie_store, **session_options
