# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.traffic_sampling_rules
#
#  id                :integer(2)       not null, primary key
#  dst_prefix        :string           default(""), not null
#  dump_rate         :float            default(0.0), not null
#  recording_rate    :float            default(0.0), not null
#  src_prefix        :string           default(""), not null
#  customer_id       :integer(4)
#  customers_auth_id :integer(4)
#  dump_level_id     :integer(2)       default(0), not null
#
# Indexes
#
#  traffic_sampling_rules_customer_id_idx        (customer_id)
#  traffic_sampling_rules_customers_auth_id_idx  (customers_auth_id)
#
# Foreign Keys
#
#  traffic_sampling_rules_customer_id_fkey        (customer_id => contractors.id)
#  traffic_sampling_rules_customers_auth_id_fkey  (customers_auth_id => customers_auth.id)
#
FactoryBot.define do
  factory :traffic_sampling_rule, class: 'Routing::TrafficSamplingRule' do
    src_prefix { '' }
    dst_prefix { '' }

    dump_level_id { Routing::TrafficSamplingRule::DUMP_LEVEL_CAPTURE_ALL }
    dump_rate { 100 }
    recording_rate { 100 }
  end
end
