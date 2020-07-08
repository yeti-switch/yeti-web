# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.traffic_vendor_accounts
#
#  id         :bigint(8)        not null, primary key
#  amount     :decimal(, )
#  count      :bigint(8)        not null
#  duration   :bigint(8)        not null
#  profit     :decimal(, )
#  timestamp  :datetime         not null
#  account_id :integer(4)       not null
#
# Indexes
#
#  traffic_vendor_accounts_account_id_timestamp_idx  (account_id,timestamp) UNIQUE
#

class Stats::TrafficVendorAccount < Stats::Traffic
  self.table_name = 'stats.traffic_vendor_accounts'
end
