# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.rateplans
#
#  id                     :integer(4)       not null, primary key
#  name                   :string
#  send_quality_alarms_to :integer(4)       is an Array
#  uuid                   :uuid             not null
#  external_id            :bigint(8)
#  profit_control_mode_id :integer(2)       default(1), not null
#
# Indexes
#
#  rateplans_external_id_key  (external_id) UNIQUE
#  rateplans_name_unique      (name) UNIQUE
#  rateplans_uuid_key         (uuid) UNIQUE
#
FactoryBot.define do
  factory :rateplan, class: 'Routing::Rateplan' do
    sequence(:name) { |n| "rateplan#{n}" }

    profit_control_mode_id { Routing::RateProfitControlMode::MODE_PER_CALL }

    trait :with_uuid do
      uuid { SecureRandom.uuid }
    end

    factory :rateplan_with_customer do
      after(:create) do |record|
        create :customers_auth, rateplan: record
      end
    end

    trait :filled do
      with_uuid

      after(:create) do |record|
        create_list(:customers_auth, 2, rateplan: record)
        create_list(:rate_group, 2, rateplans: [record])
      end
    end
  end
end
