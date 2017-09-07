class Api::Rest::Admin::CodecGroupResource < JSONAPI::Resource

  attributes :name
  has_many :codecs, class_name: 'CodecGroupCodec'
end
