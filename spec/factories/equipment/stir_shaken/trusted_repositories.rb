# frozen_string_literal: true

# == Schema Information
#
# Table name: stir_shaken_trusted_repositories
#
#  id                         :integer(2)       not null, primary key
#  url_pattern                :string           not null
#  validate_https_certificate :boolean          default(TRUE), not null
#  updated_at                 :timestamptz
#
FactoryBot.define do
  factory :stir_shaken_trusted_repository, class: Equipment::StirShaken::TrustedRepository do
    sequence(:url_pattern) { |n| "https://test_#{n}" }
    validate_https_certificate { true }
    updated_at { Time.now.utc.change(usec: 0) }
  end
end
