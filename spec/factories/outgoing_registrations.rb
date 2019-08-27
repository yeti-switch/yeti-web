# frozen_string_literal: true

FactoryGirl.define do
  factory :outgoing_registration, class: RealtimeData::OutgoingRegistration do
    trait :filled do
      sequence(:id, 1_000)
      domain 'qwe.asd.com'
      user 'user_name'
      state 'some_state'
      auth_user 'auth.user'
      display_name 'display.name'
      contact 'some.contact'
      proxy ''
      expires { 5.minutes.from_now.utc.to_s(:db) }
      expires_left '5 minutes'
      last_error_code ''
      last_error_initiator ''
      last_error_reason ''
      last_request_time { Time.now.utc.to_s(:db) }
      last_succ_reg_time { Time.now.utc.to_s(:db) }
      attempt 1
      max_attempts 5
      retry_delay 2
    end
  end
end
