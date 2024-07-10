# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.areas
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  areas_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :area, class: Routing::Area do
    sequence(:name) { |n| "Routing_Area_#{n}" }

    trait :filled do
      prefixes { build_list :area_prefix, 2 }
      src_detection_rules { build_list :routing_tag_detection_rule, 2 }
      dst_detection_rules { build_list :routing_tag_detection_rule, 2 }
    end
  end
end
