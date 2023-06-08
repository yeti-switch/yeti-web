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

  StatRow = Struct.new(
    :account_id,
    :account_external_id,
    :customer_auth_id,
    :customer_auth_external_id,
    :customer_auth_external_type,
    :customer_price
  )

  belongs_to :customer_auth, class_name: 'CustomersAuth', optional: true

  def self.last24_hour
    from_time = 24.hours.ago.beginning_of_hour

    joins(customer_auth: :account)
      .where('timestamp >= ?', from_time)
      .group(
        :customer_auth_id,
        Arel.sql('accounts.external_id')
      )
      .pluck(
        Arel.sql('customers_auth.account_id'),
        Arel.sql('accounts.external_id AS account_external_id'),
        :customer_auth_id,
        Arel.sql('customers_auth.external_id AS customer_auth_external_id'),
        Arel.sql('customers_auth.external_type AS customer_auth_external_type'),
        Arel.sql('SUM(customer_price) AS customer_price')
      )
  end
end
