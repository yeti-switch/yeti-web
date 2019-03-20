# frozen_string_literal: true

class Api::Rest::Admin::CodecGroupResource < ::BaseResource
  attributes :name
  has_many :codecs, class_name: 'CodecGroupCodec'

  filter :name # DEPRECATED

  ransack_filter :name, type: :string
end
