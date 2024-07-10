# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.rate_groups
#
#  id          :integer(4)       not null, primary key
#  name        :string           not null
#  external_id :bigint(8)
#
# Indexes
#
#  rate_groups_external_id_key  (external_id) UNIQUE
#  rate_groups_name_key         (name) UNIQUE
#
FactoryBot.define do
  factory :rate_group, class: Routing::RateGroup do
    sequence(:name) { |n| "rateplan#{n}" }
    sequence(:external_id)

    trait :filled do
      destinations { build_list :destination, 2 }
    end
  end
end
