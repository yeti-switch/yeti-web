# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.customer_traffic_report_schedulers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  period_id   :integer          not null
#  customer_id :integer          not null
#  last_run_at :datetime
#  next_run_at :datetime
#  send_to     :integer          is an Array
#

class Report::CustomerTrafficScheduler < Cdr::Base
  self.table_name = 'reports.customer_traffic_report_schedulers'

  belongs_to :customer, -> { where(customer: true) }, class_name: 'Contractor', foreign_key: :customer_id
  belongs_to :period, class_name: 'Report::SchedulerPeriod', foreign_key: :period_id
  validates_presence_of :customer, :period

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
  end

  def send_to=(send_to_ids)
    self[:send_to] = send_to_ids.reject(&:blank?)
  end
end
