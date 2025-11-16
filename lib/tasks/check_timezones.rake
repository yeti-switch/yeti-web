# frozen_string_literal: true

task check_timezones: :environment do |_t, _args|
  Rails.logger.info "\e[1m\e[32mChecking Scheduler timezones:\e[0m"

  bad_schedulers = 0
  System::Scheduler.where('timezone not in (?)', Yeti::TimeZoneHelper.all).find_each do |scheduler|
    Rails.logger.info "      \e[1m\e[33mWrong timezone #{scheduler.timezone} in scheduler id=#{scheduler.id}\e[0m"
    bad_schedulers = 1
  end

  if bad_schedulers != 0
    Rails.logger.info "      \e[1m\e[31mACTION REQUIRED: You SHOULD fix timezones in schedulers\n\e[0m"
  else
    Rails.logger.info "      \e[1m\e[32mOK\n\e[0m"
  end

  Rails.logger.info "\e[1m\e[32mChecking CDR Exports timezones(OPTIONAL):\e[0m"

  bad_exports = 0
  CdrExport.where('time_zone_name not in (?)', Yeti::TimeZoneHelper.all).find_each do |s|
    Rails.logger.info "      \e[1m\e[33mWrong timezone #{s.time_zone_name} in CDR Export id=#{s.id}\e[0m"
    bad_exports = 1
  end

  if bad_exports == 0
    Rails.logger.info "      \e[1m\e[32mOK\n\e[0m"
  end

  if bad_schedulers != 0 || bad_exports != 0
    exit 100
  end
end
