# frozen_string_literal: true

FactoryGirl.define do
  factory :network, class: System::Network do
    name 'US Eagle Mobile'
    network_type { System::NetworkType.take || FactoryGirl.create(:network_type) }
  end
end
