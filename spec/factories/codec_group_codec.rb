# frozen_string_literal: true

FactoryGirl.define do
  factory :codec_group_codec do
    sequence(:priority, 10)
    sequence(:codec_id, 10)
    dynamic_payload_type 100
    codec_group_id 5
  end
end
