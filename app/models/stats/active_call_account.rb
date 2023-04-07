# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_call_accounts
#
#  id               :bigint(8)        not null, primary key
#  originated_count :integer(4)       not null
#  terminated_count :integer(4)       not null
#  created_at       :timestamptz
#  account_id       :integer(4)       not null
#
# Indexes
#
#  active_call_accounts_account_id_created_at_idx  (account_id,created_at)
#

class Stats::ActiveCallAccount < Stats::Base
  self.table_name = 'stats.active_call_accounts'
  belongs_to :account, optional: true

  include ::Chart
  self.chart_entity_column = :account_id
  self.chart_entity_klass = Account

  class << self
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
