# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.customer_auth_stats
#
#  id                    :bigint(8)        not null, primary key
#  calls_count           :integer(4)       default(0), not null
#  customer_duration     :integer(4)       default(0), not null
#  customer_price        :decimal(, )      default(0.0), not null
#  customer_price_no_vat :decimal(, )      default(0.0), not null
#  duration              :integer(4)       default(0), not null
#  timestamp             :timestamptz      not null
#  vendor_price          :decimal(, )      default(0.0), not null
#  customer_auth_id      :integer(4)       not null
#
# Indexes
#
#  customer_auth_stats_customer_auth_id_timestamp_idx  (customer_auth_id,timestamp) UNIQUE
#
class Stats::CustomerAuthStats < Stats::Traffic
  self.table_name = 'stats.customer_auth_stats'
end
