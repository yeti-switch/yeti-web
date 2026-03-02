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
  factory :stir_shaken_trusted_certificate, class: 'Equipment::StirShaken::TrustedCertificate' do
    sequence(:name) { |n| "test_#{n}" }
    sequence(:certificate) { |n| "----BEGIN CERTIFICATE----\n test_#{n}\n----END CERTIFICATE----" }
    updated_at { Time.now.utc.change(usec: 0) }

    trait :with_certificate do
      after(:build) do |record, _evaluator|
        cert_pem, = StirShakenCertificateHelper.build_cert_pem
        record.certificate = cert_pem
      end
    end

    trait :with_tn_auth_list do
      transient do
        tn_auth_entries { [{ type: :spc, value: '1234' }] }
      end

      after(:build) do |record, evaluator|
        cert_pem, = StirShakenCertificateHelper.build_cert_pem(tn_auth_entries: evaluator.tn_auth_entries)
        record.certificate = cert_pem
      end
    end

    trait :with_certificate_chain do
      transient do
        tn_auth_entries { [] }
      end

      after(:build) do |record, evaluator|
        chain_pem, = StirShakenCertificateHelper.build_cert_chain_pem(tn_auth_entries: evaluator.tn_auth_entries)
        record.certificate = chain_pem
      end
    end
  end
end
