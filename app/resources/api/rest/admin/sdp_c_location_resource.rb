# frozen_string_literal: true

class Api::Rest::Admin::SdpCLocationResource < JSONAPI::Resource
  immutable
  attributes :name
  filter :name
end
