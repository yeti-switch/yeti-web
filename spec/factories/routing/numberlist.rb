# frozen_string_literal: true

FactoryBot.define do
  factory :numberlist, class: Routing::Numberlist do
    sequence(:name) { |n| "numberlist#{n}" }

    association :lua_script

    mode_id { Routing::Numberlist::MODE_STRICT }
    default_action_id { Routing::Numberlist::DEFAULT_ACTION_REJECT }

    trait :filled do
      tag_action { Routing::TagAction.take }
    end

    trait :with_external_id do
      sequence(:external_id)
    end
  end
end
