# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.traffic_vendor_accounts
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  timestamp  :datetime         not null
#  duration   :integer          not null
#  count      :integer          not null
#  amount     :decimal(, )
#  profit     :decimal(, )
#

class Stats::TrafficVendorAccount < Stats::Traffic
  self.table_name = 'stats.traffic_vendor_accounts'
end
