# frozen_string_literal: true

class Api::Rest::Admin::DumpLevelResource < ::BaseResource
  immutable
  attributes :name, :log_sip, :log_rtp
  paginator :paged
  filter :name # DEPRECATED

  ransack_filter :name, type: :string
end
