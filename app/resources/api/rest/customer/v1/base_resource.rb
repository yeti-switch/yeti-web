# frozen_string_literal: true

class Api::Rest::Customer::V1::BaseResource < ::BaseResource
  abstract
  immutable
  key_type :uuid
  primary_key :uuid
  paginator :paged

  class << self
    def records(options = {})
      records = super(options)
      apply_allowed_accounts(records, options)
    end

    def apply_allowed_accounts(records, _options)
      records
    end

    def association_uuid_filter(attr, column: nil, class_name:)
      column ||= attr
      klass = class_name.constantize
      verify = ->(values) { klass.where(uuid: values).pluck(:id) }
      ransack_filter attr, type: :uuid, column: column, verify: verify
    end

    private

    def inherited(subclass)
      super
      subclass.key_type(resource_key_type)
      subclass.primary_key(_primary_key)
      subclass.paginator(_paginator)
      subclass.immutable(_immutable)
    end
  end
end
