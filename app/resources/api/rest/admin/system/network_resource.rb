# frozen_string_literal: true

class Api::Rest::Admin::System::NetworkResource < ::BaseResource
  model_name 'System::Network'
  attributes :name
  paginator :paged
  filter :name

  has_one :network_type, class_name: 'NetworkType', foreign_key: :type_id, always_include_linkage_data: true
end
