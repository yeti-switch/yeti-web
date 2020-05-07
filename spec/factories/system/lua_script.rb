# frozen_string_literal: true

FactoryGirl.define do
  factory :lua_script, class: System::LuaScript do
    sequence(:name) { |n| "LUA script_#{n}" }
    source 'arg.a="000"; table.insert(arg.v,9); return arg;'

    trait :filled do
      gateways { build_list :gateway, 2 }
      customers_auths { build_list :customers_auth, 2 }
      numberlists { build_list :numberlist, 2 }
      numberlist_items { build_list :numberlist_item, 2 }
    end
  end
end
