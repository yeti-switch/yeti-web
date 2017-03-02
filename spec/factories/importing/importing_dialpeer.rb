FactoryGirl.define do
  factory :importing_dialpeer, class: Importing::Dialpeer do
    o_id nil
    enabled true
    prefix nil
    src_rewrite_rule nil
    dst_rewrite_rule nil
    acd_limit 0
    asr_limit 0
    gateway_name nil
    gateway_id nil
    routing_group_name nil
    routing_group_id nil
    next_rate nil
    connect_fee nil
    vendor_name nil
    vendor_id nil
    account_name nil
    account_id nil
    src_rewrite_result nil
    dst_rewrite_result nil
    locked false
    priority 100
    capacity 0
    lcr_rate_multiplier 1
    initial_rate 0.0
    initial_interval 60
    next_interval 60
    valid_from '1970-01-01 00:00:00'
    valid_till '2020-01-01 00:00:00'
    gateway_group_id nil
    error_string nil
  end
end
