# frozen_string_literal: true

FactoryBot.define do
  factory :stir_shaken_signing_certificate, class: Equipment::StirShaken::SigningCertificate do
    sequence(:name) { |n| "test_#{n}" }
    sequence(:certificate) { |n| "----BEGIN CERTIFICATE----\n test_#{n}\n----END CERTIFICATE----" }
    sequence(:key) { |n| "----BEGIN PRIVATE KEY----\n test_#{n}\n----END PRIVATE KEY----" }
    sequence(:url) { |n| "https://example#{n}.com" }
    updated_at { Time.now.utc.change(usec: 0) }
  end
end
