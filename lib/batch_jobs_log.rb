# frozen_string_literal: true

module BatchJobsLog
  def success(job)
    LogicLog.create!(
      source: "#{self.class} #{job.id}",
      level: 0,
      msg: 'Success'
    )
  end

  def failure(job)
    LogicLog.create!(
      source: "#{self.class} #{job.id}",
      level: 0,
      msg: job.last_error
    )
  end

  def set_audit_log_data
    ::PaperTrail.request.whodunnit = who_is[:whodunnit]
    ::PaperTrail.request.controller_info = who_is[:controller_info]
  end
end
