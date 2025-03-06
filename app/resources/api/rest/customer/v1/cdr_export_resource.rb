# frozen_string_literal: true

class Api::Rest::Customer::V1::CdrExportResource < Api::Rest::Customer::V1::BaseResource
  model_name 'CdrExport'
  create_form 'CustomerApi::CdrExportForm'
  model_hint model: CdrExport::Base, resource: self
  paginator :paged

  before_create { _model.customer_id = context[:customer_id] }
  before_create { _model.allowed_account_ids = context[:allowed_account_ids] }

  attributes :filters,
             :status,
             :rows_count,
             :created_at,
             :updated_at

  has_one :account, relation_name: :customer_account, foreign_key_on: :related

  def self.default_sort
    [{ field: 'created_at', direction: :desc }]
  end

  ransack_filter :status, type: :enum, collection: CdrExport::STATUSES
  ransack_filter :rows_count, type: :number
  ransack_filter :created_at, type: :datetime
  ransack_filter :updated_at, type: :datetime
  association_uuid_filter :account_id, class_name: 'Account'

  def filters
    _model.filters.as_json.slice(*CustomerApi::CdrExportForm::ALLOWED_FILTERS)
  end

  def self.creatable_fields(_context)
    %i[filters account]
  end

  def self.updatable_fields(_context)
    []
  end

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    scope = records
            .where.not(customer_account_id: nil)
            .joins(:customer_account)
            .where(accounts: { contractor_id: context[:customer_id] })
    scope = scope.where(customer_account_id: context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end
end
