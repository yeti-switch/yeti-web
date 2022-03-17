# frozen_string_literal: true

# == Schema Information
#
# Table name: reports.customer_traffic_report
#
#  id          :bigint(8)        not null, primary key
#  completed   :boolean          default(FALSE), not null
#  date_end    :datetime
#  date_start  :datetime
#  send_to     :integer(4)       is an Array
#  created_at  :datetime
#  customer_id :integer(4)       not null
#

class Report::CustomerTraffic < Cdr::Base
  self.table_name = 'reports.customer_traffic_report'

  # *NOTE* Creation from user input should be performed only through Report::CustomerTrafficForm
  # *NOTE* Creation from business logic should be performed only through CreateReport::CustomerTraffic

  has_many :customer_traffic_data_by_vendor,
           class_name: 'Report::CustomerTrafficDataByVendor',
           foreign_key: :report_id,
           dependent: :delete_all

  has_many :customer_traffic_data_by_destination,
           class_name: 'Report::CustomerTrafficDataByDestination',
           foreign_key: :report_id,
           dependent: :delete_all

  has_many :customer_traffic_data_full,
           class_name: 'Report::CustomerTrafficDataFull',
           foreign_key: :report_id,
           dependent: :delete_all

  belongs_to :customer, -> { where customer: true }, class_name: 'Contractor', foreign_key: :customer_id

  validates :date_start, :date_end, :customer, presence: true

  def report_records_by_vendor
    customer_traffic_data_by_vendor.preload(:vendor)
  end

  def report_records_by_destination
    # customer_traffic_data_by_destination.includes(:country, :network)
    customer_traffic_data_by_destination.report_records
  end

  def report_records_full
    customer_traffic_data_full.preload(:vendor, :country, :network)
  end

  def display_name
    id.to_s
  end
end
