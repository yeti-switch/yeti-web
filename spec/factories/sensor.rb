FactoryGirl.define do
  factory :sensor, class: System::Sensor do
    name nil
    mode_id 1
    source_interface nil
    target_mac nil
    source_ip nil
    target_ip nil
  end
end
