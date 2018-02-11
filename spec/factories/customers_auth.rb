FactoryGirl.define do
  factory :customers_auth, class: CustomersAuth do
    sequence(:name) { |n| "customers_auth_#{n}"}
    ip '0.0.0.0'
    diversion_policy_id 1
    dump_level_id 1

    association :customer, factory: :contractor, customer: true
    association :rateplan
    association :routing_plan
    association :gateway
    association :account


    src_rewrite_rule nil
    src_rewrite_result nil
    dst_rewrite_rule nil
    dst_rewrite_result nil
    src_prefix ''
    dst_prefix ''
    x_yeti_auth nil
    pop_id nil
    uri_domain nil
    src_name_rewrite_rule nil
    src_name_rewrite_result nil
    diversion_rewrite_rule nil
    diversion_rewrite_result nil
    dst_numberlist_id nil
    src_numberlist_id nil
    allow_receive_rate_limit false
    send_billing_information false
  end
end
