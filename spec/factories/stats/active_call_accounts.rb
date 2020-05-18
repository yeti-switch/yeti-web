# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.active_call_accounts
#
#  id               :integer          not null, primary key
#  account_id       :integer          not null
#  originated_count :integer          not null
#  terminated_count :integer          not null
#  created_at       :datetime
#

FactoryBot.define do
  factory :active_call_account, class: Stats::ActiveCallAccount do
    terminated_count { 0 }
    originated_count { 0 }
  end
end
