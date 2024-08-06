# frozen_string_literal: true

# == Schema Information
#
# Table name: codec_groups
#
#  id    :integer(4)       not null, primary key
#  name  :string           not null
#  ptime :integer(2)
#
# Indexes
#
#  codec_groups_name_key  (name) UNIQUE
#
FactoryBot.define do
  factory :codec_group, class: 'CodecGroup' do
    sequence(:name) { |n| "codec_group#{n}" }
    codec_group_codecs do
      [
        build(:codec_group_codec, codec_id: 6, priority: 1),
        build(:codec_group_codec, codec_id: 7, priority: 2)
      ]
    end
  end
end
