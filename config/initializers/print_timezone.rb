# frozen_string_literal: true

Rails.application.config.after_initialize do
  warn "App Timezone #{Rails.application.config.time_zone}"
  warn "Yeti DB timezone #{::SqlCaller::Yeti.current_timezone}"
  warn "CDR DB timezone #{::SqlCaller::Cdr.current_timezone}"
  warn "ActiveRecord timezone #{Rails.application.config.active_record.default_timezone}"
  ApplicationRecord.clear_active_connections!
  ApplicationRecord.flush_idle_connections!
  Cdr::Base.clear_active_connections!
  Cdr::Base.flush_idle_connections!
rescue StandardError => e
  warn "suppressed error during timezone print <#{e.class}>: #{e.message}"
end
