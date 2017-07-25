FactoryGirl.define do
  factory :destination, class: Destination do
    prefix nil
    connect_fee 0
    enabled true
    reject_calls false
    initial_interval 60
    next_interval 60
    initial_rate 0
    next_rate 0
    rate_policy_id 1
    dp_margin_fixed 0
    dp_margin_percent 0
    use_dp_intervals false
    association :rateplan
  end
end
