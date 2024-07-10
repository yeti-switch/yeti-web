# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.network_prefixes
#
#  id                :integer(4)       not null, primary key
#  number_max_length :integer(2)       default(100), not null
#  number_min_length :integer(2)       default(0), not null
#  prefix            :string           not null
#  uuid              :uuid             not null
#  country_id        :integer(4)
#  network_id        :integer(4)
#
# Indexes
#
#  network_prefixes_prefix_key        (prefix) UNIQUE
#  network_prefixes_prefix_range_idx  (((prefix)::prefix_range)) USING gist
#  network_prefixes_uuid_key          (uuid) UNIQUE
#
# Foreign Keys
#
#  network_prefixes_country_id_fkey  (country_id => countries.id)
#  network_prefixes_network_id_fkey  (network_id => networks.id)
#

FactoryBot.define do
  factory :network_prefix, class: System::NetworkPrefix do
    # Max prefix length in db/network_prefixes.yml is 12.
    # To avoid duplication we create prefixes wih length 13+.
    base_prefix = '1' * 12
    sequence(:prefix) { |n| base_prefix + n.to_s }
    network { System::Network.take! }
    country { System::Country.take! }
    uuid { SecureRandom.uuid }
  end
end
