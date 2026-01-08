# frozen_string_literal: true

# == Schema Information
#
# Table name: dns.dns_records
#
#  id            :integer(4)       not null, primary key
#  content       :string           not null
#  name          :string           not null
#  record_type   :string           not null
#  contractor_id :integer(4)
#  zone_id       :integer(2)       not null
#
# Indexes
#
#  dns_records_contractor_id_idx  (contractor_id)
#  dns_records_zone_id_idx        (zone_id)
#
# Foreign Keys
#
#  dns_records_contractor_id_fkey  (contractor_id => contractors.id)
#  dns_records_zone_id_fkey        (zone_id => dns.dns_zones.id)
#
FactoryBot.define do
  factory :dns_record, class: 'Equipment::Dns::Record' do
    sequence(:name) { |n| "record#{n}" }
    record_type { 'A' }
    content { '192.168.1.2' }

    association :zone, factory: :dns_zone
    association :contractor, factory: :contractor, customer: true
  end
end
