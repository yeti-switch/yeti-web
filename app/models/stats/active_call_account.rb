# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_call_accounts
#
#  id               :bigint(8)        not null, primary key
#  originated_count :integer(4)       not null
#  terminated_count :integer(4)       not null
#  created_at       :datetime
#  account_id       :integer(4)       not null
#
# Indexes
#
#  active_call_accounts_account_id_created_at_idx  (account_id,created_at)
#

class Stats::ActiveCallAccount < Stats::Base
  self.table_name = 'stats.active_call_accounts'
  belongs_to :account

  include ::Chart
  self.chart_entity_column = :account_id
  self.chart_entity_klass = Account

  class << self
    def create_stats(customer_calls = {}, vendor_calls = {}, now_time)
      calls = Hash.new { |h, k| h[k] = { terminated_count: 0, originated_count: 0 } }
      customer_calls.each do |account_id, sub_calls|
        calls[account_id.to_i][:originated_count] = sub_calls.count
      end
      vendor_calls.each do |account_id, sub_calls|
        calls[account_id.to_i][:terminated_count] = sub_calls.count
      end
      missing_foreign_ids = Account.pluck(:id) - calls.keys

      transaction do
        calls.each do |account_id, opts|
          create!(
            created_at: now_time,
            originated_count: opts[:originated_count],
            terminated_count: opts[:terminated_count],
            account_id: account_id
          )
        end
        missing_foreign_ids.each do |foreign_id|
          create!(
            created_at: now_time,
            originated_count: 0,
            terminated_count: 0,
            account_id: foreign_id
          )
        end
      end
    end

    def to_chart_all(account_id)
      lines = to_chart_vendor(account_id, area: false, key: 'Vendor')
      lines.concat to_chart_customer(account_id, area: false, key: 'Account')
      lines
    end

    def to_chart_customer(account_id, options = {})
      options = options.merge(count_column: :originated_count)
      to_chart(account_id, options)
    end

    def to_chart_vendor(account_id, options = {})
      options = options.merge(count_column: :terminated_count)
      to_chart(account_id, options)
    end
  end
end
