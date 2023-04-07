# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.vendor_traffic_report_schedulers
#
#  id          :integer(4)       not null, primary key
#  last_run_at :timestamptz
#  next_run_at :timestamptz
#  send_to     :integer(4)       is an Array
#  created_at  :timestamptz
#  period_id   :integer(4)       not null
#  vendor_id   :integer(4)       not null
#
# Foreign Keys
#
#  vendor_traffic_report_schedulers_period_id_fkey  (period_id => scheduler_periods.id)
#

class Report::VendorTrafficScheduler < Cdr::Base
  self.table_name = 'reports.vendor_traffic_report_schedulers'

  belongs_to :vendor, -> { where(vendor: true) }, class_name: 'Contractor', foreign_key: :vendor_id
  belongs_to :period, class_name: 'Report::SchedulerPeriod', foreign_key: :period_id
  validates :vendor, :period, presence: true

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
