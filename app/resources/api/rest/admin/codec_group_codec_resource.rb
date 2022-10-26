# frozen_string_literal: true

class Api::Rest::Admin::CodecGroupCodecResource < BaseResource
  attributes :dynamic_payload_type, :priority, :codec_group_id, :codec_id
end
