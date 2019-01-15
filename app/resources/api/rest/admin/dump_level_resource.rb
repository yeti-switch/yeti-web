# frozen_string_literal: true

class Api::Rest::Admin::DumpLevelResource < JSONAPI::Resource
  immutable
  attributes :name, :log_sip, :log_rtp
  filter :name
end
