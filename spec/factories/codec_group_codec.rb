# frozen_string_literal: true

# == Schema Information
#
# Table name: codec_group_codecs
#
#  id                   :integer          not null, primary key
#  codec_group_id       :integer          not null
#  codec_id             :integer          not null
#  priority             :integer          default(100), not null
#  dynamic_payload_type :integer
#  format_parameters    :string
#

FactoryBot.define do
  factory :codec_group_codec do
    sequence(:priority, 10)
    dynamic_payload_type { 100 }
  end
end
