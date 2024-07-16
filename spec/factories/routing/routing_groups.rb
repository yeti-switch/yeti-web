# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_groups
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  routing_groups_name_unique  (name) UNIQUE
#
FactoryBot.define do
  factory :routing_group, class: 'Routing::RoutingGroup' do
    sequence(:name) { |n| "routing_group_#{n}" }

    trait :with_dialpeers do
      dialpeers { build_list :dialpeer, 2 }
    end
  end
end
