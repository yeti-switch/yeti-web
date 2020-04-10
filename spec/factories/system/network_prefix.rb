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

FactoryGirl.define do
  factory :network_prefix, class: System::NetworkPrefix do
    sequence(:prefix, 1_000, &:to_s)
    network { System::Network.take || FactoryGirl.create(:network) }
    country { System::Country.take || FactoryGirl.create(:country) }
    uuid { SecureRandom.uuid }
  end
end
