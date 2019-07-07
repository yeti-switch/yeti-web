# frozen_string_literal: true

FactoryGirl.define do
  factory :numberlist, class: Routing::Numberlist do
    sequence(:name) { |n| "numberlist#{n}" }

    association :lua_script

    after :build do |numberlist|
      numberlist.mode ||= Routing::NumberlistMode.create(id: 1, name: 'Strict number match')
      numberlist.default_action ||= Routing::NumberlistAction.create(id: 1, name: 'Reject call')
    end
  end
end
