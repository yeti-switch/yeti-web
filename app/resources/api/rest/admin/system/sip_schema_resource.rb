# frozen_string_literal: true

class Api::Rest::Admin::System::SipSchemaResource < BaseResource
  immutable
  model_name 'System::SipSchema'
  attributes :name
  paginator :paged
  filter :name
end
