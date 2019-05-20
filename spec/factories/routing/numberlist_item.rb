# frozen_string_literal: true

FactoryGirl.define do
  factory :numberlist_item, class: Routing::NumberlistItem do
    sequence(:key) { |n| "numberlist_item_#{n}" }

    association :numberlist
    association :lua_script
  end
end
