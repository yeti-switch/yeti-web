# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.service_types
#
#  id                 :integer(2)       not null, primary key
#  force_renew        :boolean          default(FALSE), not null
#  name               :string           not null
#  provisioning_class :string
#  variables          :jsonb
#
# Indexes
#
#  service_types_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :service_type, class: Billing::ServiceType do
    sequence(:name) { |n| "Service Type #{n}" }
    provisioning_class { 'Billing::Provisioning::Logging' }
    variables { { 'foo' => 'bar' } }
  end
end
