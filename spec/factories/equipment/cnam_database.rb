# frozen_string_literal: true

FactoryBot.define do
  factory :cnam_database, class: Cnam::Database do
    sequence(:name) { |n| "CNAM db script_#{n}" }
    request_lua { 'arg.a="000"; table.insert(arg.v,9); return arg;' }
    response_lua { 'arg.a="000"; table.insert(arg.v,9); return arg;' }
    association :database, factory: :cnam_database_http
  end
end
