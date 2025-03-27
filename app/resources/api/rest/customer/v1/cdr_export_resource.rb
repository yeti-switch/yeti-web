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
             :updated_at,
             :time_format,
             :time_zone_name

  has_one :account, relation_name: :customer_account, foreign_key_on: :related

  def self.default_sort
    [{ field: 'created_at', direction: :desc }]
  end

  ransack_filter :status, type: :enum, collection: CdrExport::STATUSES
  ransack_filter :rows_count, type: :number
  ransack_filter :created_at, type: :datetime
  ransack_filter :updated_at, type: :datetime
  association_uuid_filter :account_id, class_name: 'Account'

  filter :time_format, verify: :time_format_filter_verifier, apply: lambda { |records, values, _opts|
    records.where(time_format: values)
  }

  filter :time_zone_name, verify: :time_zone_name_filter_verifier, apply: lambda { |records, values, _opts|
    records.where(time_zone_name: values)
  }

  def filters
    _model.filters.as_json.slice(*CustomerApi::CdrExportForm::ALLOWED_FILTERS)
  end

  def self.creatable_fields(_context)
    %i[filters account time_format time_zone_name]
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

  def self.time_format_filter_verifier(values, _ctx)
    return if values.blank?

    values.each do |value|
      if CdrExport::ALLOWED_TIME_FORMATS.exclude?(value)
        raise JSONAPI::Exceptions::InvalidFilterValue.new(:with_timezone, value)
      end
    end

    values
  end

  def self.time_zone_name_filter_verifier(values, _ctx)
    return if values.blank?

    values.each do |value|
      unless Yeti::TimeZoneHelper.all.any? { |i| i.name == value }
        raise JSONAPI::Exceptions::InvalidFilterValue.new(:time_zone_name, value)
      end
    end

    values
  end

  private_class_method :time_format_filter_verifier
  private_class_method :time_zone_name_filter_verifier
end
