# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.lnp_resolvers
#
#  id      :integer          not null, primary key
#  name    :string           not null
#  address :string           not null
#  port    :integer          not null
#

FactoryBot.define do
  factory :lnp_resolver, class: System::LnpResolver do
    sequence(:name) { |n| "test_#{n}" }
    address { 'example.com' }
    port { 1234 }
  end
end
