# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.sensors
#
#  id               :integer(2)       not null, primary key
#  name             :string           not null
#  source_interface :string
#  source_ip        :inet
#  target_ip        :inet
#  target_mac       :macaddr
#  target_port      :integer(4)
#  use_routing      :boolean          not null
#  hep_capture_id   :integer(4)
#  mode_id          :integer(4)       not null
#
# Indexes
#
#  sensors_name_key  (name) UNIQUE
#
# Foreign Keys
#
#  sensors_mode_id_fkey  (mode_id => sensor_modes.id)
#
FactoryBot.define do
  factory :sensor, class: System::Sensor do
    sequence(:name) { |n| "sensor#{n}" }
    mode_id { 1 }
    source_interface { nil }
    target_mac { nil }
    source_ip { '192.168.0.1' }
    target_ip { '192.168.0.2' }

    trait :filled do
      gateways { build_list :gateway, 2 }
    end
  end
end
