FactoryGirl.define do
  factory :customers_auth, class: CustomersAuth do
    sequence(:name) { |n| "customers_auth_#{n}"}
    diversion_policy_id 1
    dump_level_id 1

    association :customer, factory: :contractor, customer: true
    association :rateplan
    association :routing_plan
    association :gateway
    association :account

    #ip { ['127.0.0.0/8'] } # default
    src_rewrite_rule nil
    src_rewrite_result nil
    dst_rewrite_rule nil
    dst_rewrite_result nil
    pop_id nil
    src_name_rewrite_rule nil
    src_name_rewrite_result nil
    diversion_rewrite_rule nil
    diversion_rewrite_result nil
    dst_numberlist_id nil
    src_numberlist_id nil
    allow_receive_rate_limit false
    send_billing_information false

    trait :with_incoming_auth do
      association :gateway, factory: [:gateway, :with_incoming_auth]
      require_incoming_auth true
    end

    trait :with_reject do
      reject_calls true
    end


  end
end
