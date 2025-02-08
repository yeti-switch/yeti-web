# frozen_string_literal: true

# == Schema Information
#
# Table name: ratemanagement.projects
#
#  id                           :integer(4)       not null, primary key
#  acd_limit                    :float(24)        default(0.0)
#  asr_limit                    :float(24)        default(0.0)
#  capacity                     :integer(2)
#  dst_number_max_length        :integer(2)       default(100), not null
#  dst_number_min_length        :integer(2)       default(0), not null
#  dst_rewrite_result           :string
#  dst_rewrite_rule             :string
#  enabled                      :boolean          default(TRUE), not null
#  exclusive_route              :boolean          default(FALSE), not null
#  force_hit_rate               :float
#  initial_interval             :integer(4)       default(1)
#  keep_applied_pricelists_days :integer(2)       default(30), not null
#  lcr_rate_multiplier          :decimal(, )      default(1.0)
#  name                         :string           not null
#  next_interval                :integer(4)       default(1)
#  priority                     :integer(4)       default(100), not null
#  reverse_billing              :boolean          default(FALSE)
#  routing_tag_ids              :integer(2)       default([]), not null, is an Array
#  short_calls_limit            :float(24)        default(1.0), not null
#  src_name_rewrite_result      :string
#  src_name_rewrite_rule        :string
#  src_rewrite_result           :string
#  src_rewrite_rule             :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  account_id                   :integer(4)       not null
#  gateway_group_id             :integer(4)
#  gateway_id                   :integer(4)
#  routeset_discriminator_id    :integer(2)       not null
#  routing_group_id             :integer(4)       not null
#  routing_tag_mode_id          :integer(2)       default(0)
#  vendor_id                    :integer(4)       not null
#
# Indexes
#
#  index_ratemanagement.projects_on_account_id                 (account_id)
#  index_ratemanagement.projects_on_gateway_group_id           (gateway_group_id)
#  index_ratemanagement.projects_on_gateway_id                 (gateway_id)
#  index_ratemanagement.projects_on_name                       (name) UNIQUE
#  index_ratemanagement.projects_on_routeset_discriminator_id  (routeset_discriminator_id)
#  index_ratemanagement.projects_on_routing_group_id           (routing_group_id)
#  index_ratemanagement.projects_on_routing_tag_mode_id        (routing_tag_mode_id)
#  index_ratemanagement.projects_on_vendor_id                  (vendor_id)
#
# Foreign Keys
#
#  fk_rails_2016c4d0a1  (routing_group_id => routing_groups.id)
#  fk_rails_8c0fbee7b0  (routing_tag_mode_id => routing_tag_modes.id)
#  fk_rails_9da44a0caf  (gateway_group_id => gateway_groups.id)
#  fk_rails_ab15e0e646  (gateway_id => gateways.id)
#  fk_rails_bba2bcfb14  (account_id => accounts.id)
#  fk_rails_ca9d46244c  (routeset_discriminator_id => routeset_discriminators.id)
#  fk_rails_ce692652ea  (vendor_id => contractors.id)
#
FactoryBot.define do
  factory :rate_management_project, class: 'RateManagement::Project' do
    sequence(:name) { |n| "Project name #{n}" }
    enabled { false }
    account { nil }
    acd_limit { 0.0 }
    asr_limit { 0.0 }
    capacity { nil }
    dst_number_max_length { 100 }
    dst_number_min_length { 0 }
    dst_rewrite_result { nil }
    dst_rewrite_rule { nil }
    exclusive_route { false }
    force_hit_rate { nil }
    gateway_group { nil }
    gateway { nil }
    initial_interval { 1 }
    keep_applied_pricelists_days { 30 }
    lcr_rate_multiplier { 1.0 }
    next_interval { 1 }
    priority { 100 }
    reverse_billing { false }
    routeset_discriminator { nil }
    routing_group { nil }
    routing_tag_ids { [] }
    routing_tag_mode_id { 0 }
    short_calls_limit { 1.0 }
    src_name_rewrite_result { nil }
    src_name_rewrite_rule { nil }
    src_rewrite_result { nil }
    src_rewrite_rule { nil }
    vendor { nil }

    trait :filled do
      vendor { association :vendor }
      routeset_discriminator { association :routeset_discriminator }
      routing_group { association :routing_group }
      gateway { association :gateway, contractor: vendor }
      account { association :account, contractor: vendor }
    end

    trait :with_gateway_group do
      gateway { nil }
      gateway_group { association :gateway_group, vendor: vendor }
    end

    trait :with_routing_tags do
      transient do
        routing_tags_qty { 2 }
        routing_tags { FactoryBot.create_list(:routing_tag, routing_tags_qty) }
      end

      routing_tag_ids { routing_tags.map(&:id) }
    end
  end
end
