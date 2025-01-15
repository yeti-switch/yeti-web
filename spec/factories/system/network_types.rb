# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.network_types
#
#  id               :integer(2)       not null, primary key
#  name             :string           not null
#  sorting_priority :integer(2)       default(999), not null
#  uuid             :uuid             not null
#
# Indexes
#
#  network_types_name_key  (name) UNIQUE
#  network_types_uuid_key  (uuid) UNIQUE
#
FactoryBot.define do
  factory :network_type, class: 'System::NetworkType' do
    sequence(:name) { |n| "Network type #{n}" }
    uuid { SecureRandom.uuid }

    trait :filled do
      networks { System::Network.take(2) }
    end
  end
end
