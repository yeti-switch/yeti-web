# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.lnp_resolvers
#
#  id      :integer(4)       not null, primary key
#  address :string           not null
#  name    :string           not null
#  port    :integer(4)       not null
#
# Indexes
#
#  lnp_resolvers_name_key  (name) UNIQUE
#

FactoryBot.define do
  factory :lnp_resolver, class: System::LnpResolver do
    sequence(:name) { |n| "test_#{n}" }
    address { 'example.com' }
    port { 1234 }
  end
end
