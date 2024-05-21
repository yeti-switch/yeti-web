# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.transactions
#
#  id          :bigint(8)        not null, primary key
#  amount      :decimal(, )      not null
#  description :string
#  uuid        :uuid             not null
#  created_at  :timestamptz      not null
#  account_id  :integer(4)       not null
#  service_id  :bigint(8)
#
# Indexes
#
#  transactions_account_id_idx  (account_id)
#  transactions_service_id_idx  (service_id)
#  transactions_uuid_idx        (uuid)
#
# Foreign Keys
#
#  transactions_account_id_fkey  (account_id => accounts.id)
#
FactoryBot.define do
  factory :billing_transaction, class: Billing::Transaction do
    transient do
      spent { true }
    end

    amount { (spent ? 1 : -1) * (rand(1..100) + rand.round(2)) }
    account { service&.account || FactoryBot.create(:account) }
    service { FactoryBot.create(:service, account:) }
  end
end
