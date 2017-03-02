# == Schema Information
#
# Table name: reports.vendor_traffic_report_schedulers
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  period_id   :integer          not null
#  vendor_id   :integer          not null
#  send_to     :integer          is an Array
#  last_run_at :datetime
#  next_run_at :datetime
#

class Report::VendorTrafficScheduler < Cdr::Base
  self.table_name='reports.vendor_traffic_report_schedulers'

  belongs_to :vendor, -> { where(vendor: true) }, class_name: Contractor, foreign_key: :vendor_id
  belongs_to :period, class_name: Report::SchedulerPeriod, foreign_key: :period_id
  validates_presence_of :vendor, :period

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
    if self.send_to.present?  and self.send_to.any?
      self.errors.add(:send_to, :invalid) if contacts.count != self.send_to.count
    end
  end

  def send_to=(send_to_ids)
    self[:send_to] = send_to_ids.reject {|i| i.blank? }
  end

end
