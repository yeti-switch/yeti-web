# frozen_string_literal: true

# == Schema Information
#
# Table name: dns.dns_zones
#
#  id        :integer(2)       not null, primary key
#  expire    :integer(2)       default(1800), not null
#  minimum   :integer(2)       default(3600), not null
#  name      :string           not null
#  refresh   :integer(2)       default(600), not null
#  retry     :integer(2)       default(600), not null
#  serial    :bigint(8)        default(0), not null
#  soa_mname :string           not null
#  soa_rname :string           not null
#
# Indexes
#
#  dns_zones_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :dns_zone, class: 'Equipment::Dns::Zone' do
    sequence(:name) { |n| "zone#{n}.tld" }
    soa_rname { 'admin.example.com' }
    soa_mname { 'ns1.example.com' }
  end
end
