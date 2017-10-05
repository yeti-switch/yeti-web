class Api::Rest::Admin::CodecGroupResource < JSONAPI::Resource

  attributes :name
  has_many :codecs, class_name: 'CodecGroupCodec'

  filter :name
end
