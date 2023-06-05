# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.jobs
#
#  id             :bigint(8)        not null, primary key
#  last_duration  :decimal(, )
#  last_exception :string
#  last_run_at    :datetime
#  name           :string           not null
#
class CronJobInfo < ApplicationRecord
  self.table_name = 'sys.jobs'

  delegate :cron_line, :repeat_interval, to: :handler_class

  def last_success
    return if last_run_at.nil?

    last_exception.nil?
  end

  def handler_class
    "Jobs::#{name}".constantize
  end
end
