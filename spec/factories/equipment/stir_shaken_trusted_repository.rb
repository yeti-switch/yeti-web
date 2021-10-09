# frozen_string_literal: true

FactoryBot.define do
  factory :stir_shaken_trusted_repository, class: Equipment::StirShaken::TrustedRepository do
    sequence(:url_pattern) { |n| "https://test_#{n}" }
    validate_https_certificate { true }
    updated_at { Time.now.utc.change(usec: 0) }
  end
end
