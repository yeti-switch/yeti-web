# frozen_string_literal: true

class Api::Rest::Admin::Routing::AreaPrefixResource < ::BaseResource
  model_name 'Routing::AreaPrefix'

  attributes :prefix

  paginator :paged

  has_one :area, class_name: 'Area', always_include_linkage_data: true

  ransack_filter :prefix, type: :string
end
