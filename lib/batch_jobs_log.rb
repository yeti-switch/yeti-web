# frozen_string_literal: true

module BatchJobsLog
  extend ActiveSupport::Concern

  included do
    around_perform :with_logic_log
  end

  private

  def with_logic_log
    Rails.logger.info { "Delayed::Worker.plugins #{Delayed::Worker.plugins}" }
    result = yield
    success
    result
  rescue StandardError => e
    failure(e)
    raise e
  end

  def success
    LogicLog.create!(
        source: "#{self.class} #{provider_job_id}",
        level: 0,
        msg: 'Success'
      )
  end

  def failure(error)
    LogicLog.create!(
        source: "#{self.class} #{provider_job_id}",
        level: 0,
        msg: "Error: #{error.message}\nchanges: #{arguments[2]}\nclass: #{arguments[0]}\nqueue: #{queue_name}\nsql: #{arguments[1]}"
      )
    raise error
  end

  def set_audit_log_data
    ::PaperTrail.request.whodunnit = who_is[:whodunnit]
    ::PaperTrail.request.controller_info = who_is[:controller_info]
  end
end
