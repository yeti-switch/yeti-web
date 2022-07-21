# frozen_string_literal: true

FactoryBot.define do
  factory :cnam_database_http, class: Cnam::DatabaseHttp do
    url { 'https://example.com/{pai}' }
    timeout { 15_000 }
  end
end
