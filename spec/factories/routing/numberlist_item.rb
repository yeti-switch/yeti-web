# frozen_string_literal: true

FactoryBot.define do
  factory :numberlist_item, class: Routing::NumberlistItem do
    sequence(:key) { |n| "numberlist_item_#{n}" }

    association :numberlist
    association :lua_script

    action_id { Routing::NumberlistItem::ACTION_REJECT }

    trait :filled do
      tag_action { Routing::TagAction.take }
    end
  end
end
