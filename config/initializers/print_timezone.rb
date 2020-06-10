# frozen_string_literal: true

begin
  warn "App Timezone #{Rails.application.config.time_zone}"
  warn "Yeti DB timezone #{::SqlCaller::Yeti.current_timezone}"
  warn "CDR DB timezone #{::SqlCaller::Cdr.current_timezone}"
  warn "ActiveRecord timezone #{Rails.application.config.active_record.default_timezone}"
rescue StandardError => e
  warn "suppressed error during timezone print <#{e.class}>: #{e.message}"
end
