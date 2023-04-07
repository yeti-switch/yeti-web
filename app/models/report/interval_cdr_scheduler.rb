# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_interval_report_schedulers
#
#  id              :integer(4)       not null, primary key
#  aggregate_by    :string
#  filter          :string
#  group_by        :string           is an Array
#  interval_length :integer(4)
#  last_run_at     :timestamptz
#  next_run_at     :timestamptz
#  send_to         :integer(4)       is an Array
#  created_at      :timestamptz
#  aggregator_id   :integer(4)
#  period_id       :integer(4)       not null
#
# Foreign Keys
#
#  cdr_interval_report_schedulers_period_id_fkey  (period_id => scheduler_periods.id)
#

class Report::IntervalCdrScheduler < Cdr::Base
  self.table_name = 'reports.cdr_interval_report_schedulers'

  belongs_to :period, class_name: 'Report::SchedulerPeriod', foreign_key: :period_id
  belongs_to :aggregation_function, class_name: 'Report::IntervalAggregator', foreign_key: :aggregator_id, optional: true

  validates :period, :interval_length, :aggregation_function, :aggregate_by, presence: true

  include Hints

  def contacts
    @contacts ||= Billing::Contact.where(id: send_to)
  end

  before_create do
    self.next_run_at = reschedule(Time.now).next_run_at
  end

  def reschedule(time_now)
    period.time_data(time_now)
  end

  validate do
    if send_to.present? && send_to.any?
      errors.add(:send_to, :invalid) if contacts.count != send_to.count
    end
    # TODO: validation for group by
  end

  def send_to=(send_to_ids)
    self[:send_to] = send_to_ids.reject(&:blank?)
  end

  def group_by=(value)
    self[:group_by] = value.reject(&:blank?)
  end

  def aggregation
    "#{aggregation_function.name}(#{aggregate_by})"
  end
end
