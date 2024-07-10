# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.cnam_databases_http
#
#  id      :integer(2)       not null, primary key
#  timeout :integer(2)       default(5), not null
#  url     :string           not null
#
FactoryBot.define do
  factory :cnam_database_http, class: Cnam::DatabaseHttp do
    url { 'https://example.com/{pai}' }
    timeout { 15_000 }
  end
end
