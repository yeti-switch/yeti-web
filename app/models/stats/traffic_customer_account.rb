# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.traffic_customer_accounts
#
#  id         :bigint(8)        not null, primary key
#  amount     :decimal(, )
#  count      :bigint(8)        not null
#  duration   :bigint(8)        not null
#  profit     :decimal(, )
#  timestamp  :timestamptz      not null
#  account_id :integer(4)       not null
#
# Indexes
#
#  traffic_customer_accounts_account_id_timestamp_idx  (account_id,timestamp) UNIQUE
#

class Stats::TrafficCustomerAccount < Stats::Traffic
  self.table_name = 'stats.traffic_customer_accounts'

  # select sum(profit),date_trunc('hour',timestamp) as ts from traffic_customer_accounts where timestamp>=now()-'2 day'::interval group by date_trunc('hour',timestamp)order by ts;
end
