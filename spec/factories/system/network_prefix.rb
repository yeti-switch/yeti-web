# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.network_prefixes
#
#  id         :integer          not null, primary key
#  prefix     :string           not null
#  network_id :integer          not null
#  country_id :integer
#

FactoryGirl.define do
  factory :network_prefix, class: System::NetworkPrefix do
    sequence(:prefix, 1_000, &:to_s)
    network { System::Network.take || FactoryGirl.create(:network) }
    country { System::Country.take || FactoryGirl.create(:country) }
  end
end
