FactoryGirl.define do
  factory :importing_destination, class: Importing::Destination do
    transient do
      _tags { create_list(:routing_tag, 2) }
    end

    o_id nil
    error_string nil

    prefix nil
    rateplan_name nil
    rateplan_id nil
    connect_fee 0
    enabled true
    reject_calls false
    initial_interval 60
    next_interval 60
    initial_rate 0
    next_rate 0
    rate_policy_name 'Fixed'
    rate_policy_id 1
    dp_margin_fixed 0
    dp_margin_percent 0
    use_dp_intervals false
    valid_from { DateTime.now }
    valid_till { DateTime.now + 5.years }
    asr_limit 0.0
    acd_limit 0.0
    short_calls_limit 0.0
    reverse_billing false

    dst_number_min_length 1
    dst_number_max_length 7

    routing_tag_ids { _tags.map(&:id) }
    routing_tag_names { _tags.map(&:name).join(', ') }
  end
end
