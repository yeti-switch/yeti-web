# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.cdr_interval_report_schedulers
#
#  id              :integer          not null, primary key
#  created_at      :datetime
#  period_id       :integer          not null
#  filter          :string
#  group_by        :string           is an Array
#  interval_length :integer
#  aggregator_id   :integer
#  aggregate_by    :string
#  send_to         :integer          is an Array
#  last_run_at     :datetime
#  next_run_at     :datetime
#

class Report::IntervalCdrScheduler < Cdr::Base
  self.table_name = 'reports.cdr_interval_report_schedulers'

  belongs_to :period, class_name: 'Report::SchedulerPeriod', foreign_key: :period_id
  belongs_to :aggregation_function, class_name: 'Report::IntervalAggregator', foreign_key: :aggregator_id

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

  def group_by=(group_by_fields)
    self[:group_by] = group_by_fields.reject(&:blank?)
  end

  def aggregation
    "#{aggregation_function.name}(#{aggregate_by})"
  end
end
