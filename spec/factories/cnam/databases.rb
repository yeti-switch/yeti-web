# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.cnam_databases
#
#  id                 :integer(2)       not null, primary key
#  database_type      :string           not null
#  drop_call_on_error :boolean          default(FALSE), not null
#  name               :string           not null
#  request_lua        :string
#  response_lua       :string
#  created_at         :timestamptz
#  database_id        :integer(2)       not null
#
# Indexes
#
#  cnam_databases_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :cnam_database, class: 'Cnam::Database' do
    sequence(:name) { |n| "CNAM db script_#{n}" }
    request_lua { 'arg.a="000"; table.insert(arg.v,9); return arg;' }
    response_lua { 'arg.a="000"; table.insert(arg.v,9); return arg;' }
    association :database, factory: :cnam_database_http
  end
end
