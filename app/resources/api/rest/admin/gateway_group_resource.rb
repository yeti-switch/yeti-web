# frozen_string_literal: true

class Api::Rest::Admin::GatewayGroupResource < BaseResource
  attributes :name

  paginator :paged

  has_one :vendor, class_name: 'Contractor', always_include_linkage_data: true

  filter :name

  ransack_filter :name, type: :string

  def self.updatable_fields(_context)
    %i[
      name
      vendor
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
