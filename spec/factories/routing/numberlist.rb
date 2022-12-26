# frozen_string_literal: true

FactoryBot.define do
  factory :numberlist, class: Routing::Numberlist do
    sequence(:name) { |n| "numberlist#{n}" }

    association :lua_script

    after :build do |numberlist|
      numberlist.mode_id = Routing::Numberlist::MODE_STRICT
      numberlist.default_action_id = Routing::Numberlist::DEFAULT_ACTION_REJECT
    end

    trait :filled do
      tag_action { Routing::TagAction.take }
    end
  end
end
