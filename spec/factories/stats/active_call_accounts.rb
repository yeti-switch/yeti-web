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

FactoryBot.define do
  factory :active_call_account, class: 'Stats::ActiveCallAccount' do
    terminated_count { 0 }
    originated_count { 0 }
  end
end
