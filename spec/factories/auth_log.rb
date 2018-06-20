FactoryGirl.define do
  factory :auth_log, class: Cdr::AuthLog do
    request_time                { 1.minute.ago }
    code                        {200}
    success                     true
    #auth_orig_transport_protocol { Equipment::TransportProtocol.take }


    association :gateway, factory: :gateway
    association :pop, factory: :pop
    association :node, factory: :node

    trait :with_id do
      id { Cdr::AuthLog.connection.select_value("SELECT nextval('auth_log.auth_log_id_seq')").to_i }
    end
  end
end
