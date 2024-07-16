# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.stir_shaken_signing_certificates
#
#  id          :integer(2)       not null, primary key
#  certificate :string           not null
#  key         :string           not null
#  name        :string           not null
#  x5u         :string           not null
#  updated_at  :timestamptz
#
FactoryBot.define do
  factory :stir_shaken_signing_certificate, class: 'Equipment::StirShaken::SigningCertificate' do
    sequence(:name) { |n| "test_#{n}" }
    sequence(:certificate) { |n| "----BEGIN CERTIFICATE----\n test_#{n}\n----END CERTIFICATE----" }
    sequence(:key) { |n| "----BEGIN PRIVATE KEY----\n test_#{n}\n----END PRIVATE KEY----" }
    sequence(:x5u) { |n| "https://example#{n}.com" }
    updated_at { Time.now.utc.change(usec: 0) }
  end
end
