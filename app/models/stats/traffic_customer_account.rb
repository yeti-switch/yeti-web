# == Schema Information
#
# Table name: stats.traffic_customer_accounts
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  timestamp  :datetime         not null
#  duration   :integer          not null
#  count      :integer          not null
#  amount     :decimal(, )
#  profit     :decimal(, )
#

class Stats::TrafficCustomerAccount < Stats::Traffic
  self.table_name = "stats.traffic_customer_accounts"

  #select sum(profit),date_trunc('hour',timestamp) as ts from traffic_customer_accounts where timestamp>=now()-'2 day'::interval group by date_trunc('hour',timestamp)order by ts;


end
