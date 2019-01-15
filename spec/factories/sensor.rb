# frozen_string_literal: true

FactoryGirl.define do
  factory :sensor, class: System::Sensor do
    sequence(:name) { |n| "sensor#{n}" }
    mode_id 1
    source_interface nil
    target_mac nil
    source_ip '192.168.0.1'
    target_ip '192.168.0.2'
  end
end
