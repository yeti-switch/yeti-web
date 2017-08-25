FactoryGirl.define do
  factory :sensor_level, class: System::SensorLevel do
    # sequence(:id, 10)
    sequence(:name) { |n| "sensor_level#{n}"}
  end
end
