module BatchJobsLog
  def success(job)
    LogicLog.create!(
      source: self.class.to_s + ' ' + job.id.to_s,
      level: 0,
      msg: 'success'
    )
  end

  def failure(job)
    LogicLog.create!(
      source: self.class.to_s + ' ' + job.id.to_s,
      level: 0,
      msg: job.last_error
    )
  end
end
