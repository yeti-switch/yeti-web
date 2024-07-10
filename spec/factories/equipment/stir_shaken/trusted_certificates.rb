# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.stir_shaken_trusted_certificates
#
#  id          :integer(2)       not null, primary key
#  certificate :string           not null
#  name        :string           not null
#  updated_at  :timestamptz
#
FactoryBot.define do
  factory :stir_shaken_trusted_certificate, class: Equipment::StirShaken::TrustedCertificate do
    sequence(:name) { |n| "test_#{n}" }
    sequence(:certificate) { |n| "----BEGIN CERTIFICATE----\n test_#{n}\n----END CERTIFICATE----" }
    updated_at { Time.now.utc.change(usec: 0) }
  end
end
