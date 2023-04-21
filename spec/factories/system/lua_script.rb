# frozen_string_literal: true

FactoryBot.define do
  factory :lua_script, class: System::LuaScript do
    sequence(:name) { |n| "LUA script_#{n}" }
    source { 'arg.a="000"; table.insert(arg.v,9); return arg;' }

    trait :filled do
      after(:create) do |record|
        FactoryBot.create_list(:gateway, 2, lua_script: record)
        FactoryBot.create_list(:customers_auth, 2, lua_script: record)
        FactoryBot.create_list(:numberlist, 2, lua_script: record)
        FactoryBot.create_list(:numberlist_item, 2, lua_script: record)
      end
    end
  end
end
