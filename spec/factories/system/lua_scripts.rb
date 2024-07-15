# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.lua_scripts
#
#  id         :integer(2)       not null, primary key
#  name       :string           not null
#  source     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  lua_scripts_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :lua_script, class: 'System::LuaScript' do
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
