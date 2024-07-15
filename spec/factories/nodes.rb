# frozen_string_literal: true

# == Schema Information
#
# Table name: nodes
#
#  id           :integer(4)       not null, primary key
#  name         :string
#  rpc_endpoint :string
#  pop_id       :integer(4)       not null
#
# Indexes
#
#  node_name_key           (name) UNIQUE
#  nodes_rpc_endpoint_key  (rpc_endpoint) UNIQUE
#
# Foreign Keys
#
#  node_pop_id_fkey  (pop_id => pops.id)
#
FactoryBot.define do
  factory :node, class: 'Node' do
    sequence(:id) { |n| n }
    sequence(:name) { |n| "Node #{n}" }
    sequence(:rpc_endpoint) { |n| "127.0.0.1:#{1 + n}" }

    association :pop, factory: :pop

    trait :filled do
      registrations { build_list :registration, 2 }
    end
  end
end
