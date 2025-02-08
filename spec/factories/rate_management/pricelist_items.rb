# frozen_string_literal: true

# == Schema Information
#
# Table name: ratemanagement.pricelist_items
#
#  id                        :bigint(8)        not null, primary key
#  acd_limit                 :float(24)
#  asr_limit                 :float(24)
#  capacity                  :integer(2)
#  connect_fee               :decimal(, )      not null
#  detected_dialpeer_ids     :bigint(8)        default([]), is an Array
#  dst_number_max_length     :integer(2)       not null
#  dst_number_min_length     :integer(2)       not null
#  dst_rewrite_result        :string
#  dst_rewrite_rule          :string
#  enabled                   :boolean
#  exclusive_route           :boolean          not null
#  force_hit_rate            :float
#  initial_interval          :integer(2)       not null
#  initial_rate              :decimal(, )      not null
#  lcr_rate_multiplier       :decimal(, )
#  next_interval             :integer(2)       not null
#  next_rate                 :decimal(, )      not null
#  prefix                    :string           default(""), not null
#  priority                  :integer(4)
#  reverse_billing           :boolean          default(FALSE)
#  routing_tag_ids           :integer(2)       default([]), not null, is an Array
#  short_calls_limit         :float(24)        not null
#  src_name_rewrite_result   :string
#  src_name_rewrite_rule     :string
#  src_rewrite_result        :string
#  src_rewrite_rule          :string
#  to_delete                 :boolean          default(FALSE), not null
#  valid_from                :datetime
#  valid_till                :datetime         not null
#  account_id                :integer(4)
#  dialpeer_id               :bigint(8)
#  gateway_group_id          :integer(4)
#  gateway_id                :integer(4)
#  pricelist_id              :integer(4)       not null
#  routeset_discriminator_id :integer(2)
#  routing_group_id          :integer(4)
#  routing_tag_mode_id       :integer(2)       default(0)
#  vendor_id                 :integer(4)
#
# Indexes
#
#  index_ratemanagement.pricelist_items_on_account_id               (account_id)
#  index_ratemanagement.pricelist_items_on_dialpeer_id              (dialpeer_id)
#  index_ratemanagement.pricelist_items_on_gateway_group_id         (gateway_group_id)
#  index_ratemanagement.pricelist_items_on_gateway_id               (gateway_id)
#  index_ratemanagement.pricelist_items_on_pricelist_id             (pricelist_id)
#  index_ratemanagement.pricelist_items_on_routing_group_id         (routing_group_id)
#  index_ratemanagement.pricelist_items_on_routing_tag_mode_id      (routing_tag_mode_id)
#  index_ratemanagement.pricelist_items_on_vendor_id                (vendor_id)
#  index_ratemanagement.pricelistitems_on_routesetdiscriminator_id  (routeset_discriminator_id)
#
# Foreign Keys
#
#  fk_rails_161e735c3a  (routing_tag_mode_id => routing_tag_modes.id)
#  fk_rails_2bccc045c8  (pricelist_id => ratemanagement.pricelists.id)
#  fk_rails_2f466a9c79  (routeset_discriminator_id => routeset_discriminators.id)
#  fk_rails_5952853742  (routing_group_id => routing_groups.id)
#  fk_rails_935caa9063  (gateway_group_id => gateway_groups.id)
#  fk_rails_995ef47750  (vendor_id => contractors.id)
#  fk_rails_e6d13b64c3  (dialpeer_id => dialpeers.id)
#  fk_rails_f7be9605b8  (account_id => accounts.id)
#  fk_rails_fc08843331  (gateway_id => gateways.id)
#
FactoryBot.define do
  factory :rate_management_pricelist_item, class: 'RateManagement::PricelistItem' do
    transient do
      project { nil }
    end
    next_interval { 2 }
    next_rate { 1 }
    sequence(:prefix, 100) { |n| "21#{n}" }
    connect_fee { 0.5 }
    initial_interval { 1 }
    initial_rate { 2 }
    routing_tag_mode_id { 0 }
    routing_tag_ids { [] }
    valid_till { 10.days.from_now.beginning_of_day.in_time_zone }
    valid_from { nil }

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
    lcr_rate_multiplier { 1.0 }
    priority { 100 }
    reverse_billing { false }
    routeset_discriminator { nil }
    routing_group { nil }
    short_calls_limit { 1.0 }
    src_name_rewrite_result { nil }
    src_name_rewrite_rule { nil }
    src_rewrite_result { nil }
    src_rewrite_rule { nil }
    vendor { nil }

    before(:create) do |record|
      record.routing_tag_ids = RoutingTagsSort.call(record.routing_tag_ids)
    end

    trait :with_pricelist do
      pricelist { association :rate_management_pricelist, :with_project }
    end

    trait :filed_from_project do
      transient do
        project { pricelist.project }
      end

      enabled { project.enabled }
      account { project.account }
      acd_limit { project.acd_limit }
      asr_limit { project.asr_limit }
      capacity { project.capacity }
      dst_number_max_length { project.dst_number_max_length }
      dst_number_min_length { project.dst_number_min_length }
      dst_rewrite_result { project.dst_rewrite_result }
      dst_rewrite_rule { project.dst_rewrite_rule }
      exclusive_route { project.exclusive_route }
      force_hit_rate { project.force_hit_rate }
      gateway_group { project.gateway_group }
      gateway { project.gateway }
      initial_interval { project.initial_interval }
      lcr_rate_multiplier { project.lcr_rate_multiplier }
      next_interval { project.next_interval }
      priority { project.priority }
      reverse_billing { project.reverse_billing }
      routeset_discriminator { project.routeset_discriminator }
      routing_group { project.routing_group }
      routing_tag_ids { project.routing_tag_ids }
      routing_tag_mode_id { project.routing_tag_mode_id }
      short_calls_limit { project.short_calls_limit }
      src_name_rewrite_result { project.src_name_rewrite_result }
      src_name_rewrite_rule { project.src_name_rewrite_rule }
      src_rewrite_result { project.src_rewrite_result }
      src_rewrite_rule { project.src_rewrite_rule }
      vendor { project.vendor }
      valid_till { pricelist.valid_till }
      valid_from { pricelist.valid_from }
    end
  end
end
