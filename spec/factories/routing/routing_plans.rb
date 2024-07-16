# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_plans
#
#  id                          :integer(4)       not null, primary key
#  max_rerouting_attempts      :integer(2)       default(10), not null
#  name                        :string           not null
#  rate_delta_max              :decimal(, )      default(0.0), not null
#  use_lnp                     :boolean          default(FALSE), not null
#  validate_dst_number_format  :boolean          default(FALSE), not null
#  validate_dst_number_network :boolean          default(FALSE), not null
#  validate_src_number_format  :boolean          default(FALSE), not null
#  validate_src_number_network :boolean          default(FALSE), not null
#  dst_numberlist_id           :integer(2)
#  external_id                 :bigint(8)
#  sorting_id                  :integer(4)       default(1), not null
#  src_numberlist_id           :integer(2)
#
# Indexes
#
#  routing_plans_dst_numberlist_id_idx  (dst_numberlist_id)
#  routing_plans_external_id_key        (external_id) UNIQUE
#  routing_plans_name_key               (name) UNIQUE
#  routing_plans_src_numberlist_id_idx  (src_numberlist_id)
#
# Foreign Keys
#
#  routing_plans_dst_numberlist_id_fkey  (dst_numberlist_id => numberlists.id)
#  routing_plans_src_numberlist_id_fkey  (src_numberlist_id => numberlists.id)
#
FactoryBot.define do
  factory :routing_plan, class: 'Routing::RoutingPlan' do
    sequence(:name) { |n| "routing_plan_#{n}" }
    sorting_id { Routing::RoutingPlan::SORTING_LCR_PRIO_CONTROL }
    rate_delta_max { 0 }
    max_rerouting_attempts { 9 }
    use_lnp { false }
    validate_dst_number_format { false }
    validate_dst_number_network { false }
    validate_src_number_format { false }
    validate_src_number_network { false }

    trait :with_static_routes do
      sorting_id { Routing::RoutingPlan::SORTING_STATIC_LCR_CONTROL }
    end

    trait :filled do
      after(:create) do |record|
        FactoryBot.create_list(:customers_auth, 2, routing_plan: record)
        FactoryBot.create_list(:routing_group, 2, routing_plans: [record])
      end
    end
  end
end
