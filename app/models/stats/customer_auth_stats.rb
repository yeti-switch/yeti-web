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

    stats = where('timestamp >= ?', from_time)
            .group(:customer_auth_id)
            .pluck(
                :customer_auth_id,
                'SUM(customer_price)'
              ).index_by(&:first)

    info = CustomersAuth.joins(:account)
                        .where(id: stats.keys)
                        .pluck(
                          :account_id,
                          'accounts.external_id',
                          :id,
                          :external_id,
                          :external_type
                        ).index_by(&:third)

    result = []
    stats.each_value do |(customer_auth_id, customer_price)|
      row = info[customer_auth_id]
      next if row.nil?

      result << StatRow.new(*row, customer_price)
    end

    result
  end
end
