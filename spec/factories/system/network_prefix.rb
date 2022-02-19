# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.network_prefixes
#
#  id                :integer          not null, primary key
#  prefix            :string           not null, uniqueness
#  network_id        :integer          not null, presence
#  country_id        :integer
#  number_min_length :integer          default(0), not null
#  number_max_length :integer          default(100), not null
#  uuid              :uuid             not null
#

FactoryBot.define do
  factory :network_prefix, class: System::NetworkPrefix do
    # Max prefix length in db/seeds/main/sys.sql is 12.
    # To avoid duplication we create prefixes wih length 13+.
    base_prefix = '1' * 12
    sequence(:prefix) { |n| base_prefix + n.to_s }
    network { System::Network.take! }
    country { System::Country.take! }
    uuid { SecureRandom.uuid }
  end
end
