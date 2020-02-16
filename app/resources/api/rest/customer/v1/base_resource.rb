# frozen_string_literal: true

class Api::Rest::Customer::V1::BaseResource < ::BaseResource
  abstract
  immutable

  def self.association_uuid_filter(attr, column: nil, class_name:)
    verify = ->(values) { class_name.constantize.where(uuid: values).pluck(:id) }
    ransack_filter attr, type: :uuid, column: column, verify: verify
  end
end
