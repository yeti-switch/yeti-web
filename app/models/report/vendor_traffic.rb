# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.vendor_traffic_report
#
#  id         :bigint(8)        not null, primary key
#  completed  :boolean          default(FALSE), not null
#  date_end   :timestamptz
#  date_start :timestamptz
#  send_to    :integer(4)       is an Array
#  created_at :timestamptz
#  vendor_id  :integer(4)       not null
#

class Report::VendorTraffic < Cdr::Base
  self.table_name = 'reports.vendor_traffic_report'

  # *NOTE* Creation from user input should be performed only through Report::VendorTrafficForm
  # *NOTE* Creation from business logic should be performed only through CreateReport::VendorTraffic

  has_many :vendor_traffic_data, class_name: 'Report::VendorTrafficData', foreign_key: :report_id, dependent: :delete_all

  belongs_to :vendor, -> { where vendor: true }, class_name: 'Contractor', foreign_key: :vendor_id

  validates :date_start, :date_end, :vendor, presence: true

  def display_name
    id.to_s
  end

  def report_records
    vendor_traffic_data.preload(:customer)
  end
end
