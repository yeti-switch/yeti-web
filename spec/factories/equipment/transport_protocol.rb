FactoryGirl.define do
  factory :transport_protocol, class: Equipment::TransportProtocol do
    sequence(:name) { |n| "protocol#{n}" }
  end
end
