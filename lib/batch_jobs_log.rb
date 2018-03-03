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
    ::PaperTrail.whodunnit = who_is[:whodunnit]
    ::PaperTrail.controller_info = who_is[:controller_info]
  end

end
