FactoryGirl.define do
  factory :destination_next_rate do
    initial_rate     0
    next_rate        0
    initial_interval 5
    next_interval    10
    connect_fee      0
    apply_time       1.hour.from_now
    applied          false

    association :destination
  end
end
