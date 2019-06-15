# frozen_string_literal: true

FactoryGirl.define do
  factory :lua_script, class: System::LuaScript do
    sequence(:name) { |n| "LUA script_#{n}" }
    source 'arg.a="000"; table.insert(arg.v,9); return arg;'
  end
end
