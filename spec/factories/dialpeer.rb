# frozen_string_literal: true

FactoryBot.define do
  factory :dialpeer, class: Dialpeer do
    sequence(:external_id)
    enabled { true }
    prefix { nil }
    src_rewrite_rule { nil }
    dst_rewrite_rule { nil }
    acd_limit { 0 }
    asr_limit { 0 }
    gateway_id { nil }
    routing_group_id { nil }
    connect_fee { 0 }
    src_rewrite_result { nil }
    dst_rewrite_result { nil }
    locked { false }
    priority { 100 }
    capacity { 1 }
    lcr_rate_multiplier { 1 }
    next_rate { 0.0 }
    initial_rate { 0.0 }
    next_interval { 60 }
    initial_interval { 60 }
    valid_from { '1970-01-01 00:00:00' }
    valid_till { '2020-01-01 00:00:00' }

    association :routing_group
    association :routeset_discriminator

    after :build do |dialpeer|
      dialpeer.vendor ||= create(:contractor, vendor: true)
      dialpeer.account ||= create(:account, contractor: dialpeer.vendor)
      dialpeer.gateway_group ||= create(:gateway_group, vendor: dialpeer.vendor) if dialpeer.gateway.blank?
    end
  end
end
