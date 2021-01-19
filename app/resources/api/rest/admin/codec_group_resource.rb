# frozen_string_literal: true

class Api::Rest::Admin::CodecGroupResource < ::BaseResource
  attributes :name

  paginator :paged

  has_many :codecs, class_name: 'CodecGroupCodec', relation_name: :codec_group_codecs, foreign_key: :codec_group_codec_ids

  filter :name # DEPRECATED

  ransack_filter :name, type: :string
end
