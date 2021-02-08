# frozen_string_literal: true

FactoryBot.define do
  factory :sip_options_prober, class: RealtimeData::SipOptionsProber do
    trait :filled do
      sequence(:id)      { |n| n }
      sequence(:node_id) { |n| n }

      append_headers           { 'H1:v1\\r\\nH2:v2' }
      contact                  { '' }
      from                     { '<sip:test@127.0.0.1>' }
      interval                 { 60 }
      last_reply_code          { 200 }
      last_reply_contact       { '<sip:10.255.0.2:5060>' }
      last_reply_delay_ms      { 2 }
      last_reply_reason        { 'OK' }
      local_tag                { '8-121C74F7-5FFDEC43000DDEBF-B8F03700' }
      name                     { 'test' }
      proxy                    { '' }
      ruri                     { 'sip:127.0.0.1' }
      sip_interface_name       { '' }
      to                       { '<sip:test@127.0.0.1>' }
    end
  end
end
