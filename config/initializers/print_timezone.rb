# frozen_string_literal: true

begin
  puts "App Timezone #{Rails.application.config.time_zone}"
  puts "Yeti DB timezone #{::SqlCaller::Yeti.current_timezone}"
  puts "CDR DB timezone #{::SqlCaller::Cdr.current_timezone}"
  puts "ActiveRecord timezone #{Rails.application.config.active_record.default_timezone}"
rescue StandardError => e
  puts "suppressed error during timezone print <#{e.class}>: #{e.message}"
end
