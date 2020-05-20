# frozen_string_literal: true

FactoryBot.define do
  factory :codec_group do
    sequence(:name) { |n| "codec_group#{n}" }
    codec_group_codecs do
      [
        build(:codec_group_codec, codec_id: 6, priority: 1),
        build(:codec_group_codec, codec_id: 7, priority: 2)
      ]
    end
  end
end
