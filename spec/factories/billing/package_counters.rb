# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.package_counters
#
#  id         :bigint(8)        not null, primary key
#  duration   :integer(4)       default(0), not null
#  exclude    :boolean          default(FALSE), not null
#  prefix     :string           not null
#  account_id :integer(4)       not null
#  service_id :bigint(8)
#
# Indexes
#
#  package_counters_account_id_idx  (account_id)
#  package_counters_prefix_idx      (((prefix)::prefix_range)) USING gist
#  package_counters_service_id_idx  (service_id)
#
# Foreign Keys
#
#  package_counters_account_id_fkey  (account_id => accounts.id)
#
FactoryBot.define do
  factory :billing_package_counter, class: 'Billing::PackageCounter' do
    account { FactoryBot.create(:account) }
    service { FactoryBot.create(:service) }
    prefix { '' }
    duration { 120 }
    exclude { false }
  end
end
