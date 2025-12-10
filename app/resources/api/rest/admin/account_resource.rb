# frozen_string_literal: true

class Api::Rest::Admin::AccountResource < BaseResource
  save_form 'AdminApi::AccountForm'
  paginator :paged

  attributes :name,
             :balance, :min_balance, :max_balance, :vat,
             :balance_low_threshold, :balance_high_threshold, :send_balance_notifications_to,
             :destination_rate_limit, :max_call_duration,
             :external_id, :uuid,
             :origination_capacity, :termination_capacity, :total_capacity,
             :send_invoices_to, :invoice_period_id, :timezone

  has_one :contractor, always_include_linkage_data: true
  has_one :invoice_template, class_name: 'InvoiceTemplate', always_include_linkage_data: true

  filter :name

  ransack_filter :name, type: :string
  ransack_filter :balance, type: :number
  ransack_filter :vat, type: :number
  ransack_filter :min_balance, type: :number
  ransack_filter :max_balance, type: :number
  ransack_filter :balance_low_threshold, type: :number, column: :balance_notification_setting_low_threshold
  ransack_filter :balance_high_threshold, type: :number, column: :balance_notification_setting_high_threshold
  ransack_filter :destination_rate_limit, type: :number
  ransack_filter :max_call_duration, type: :number
  ransack_filter :external_id, type: :number
  ransack_filter :uuid, type: :uuid
  ransack_filter :origination_capacity, type: :number
  ransack_filter :termination_capacity, type: :number
  ransack_filter :total_capacity, type: :number

  def send_balance_notifications_to
    _model.balance_notification_setting.send_to
  end

  def balance_low_threshold
    _model.balance_notification_setting.low_threshold
  end

  def balance_high_threshold
    _model.balance_notification_setting.high_threshold
  end

  def self.updatable_fields(_context)
    %i[
      name
      uuid
      external_id
      min_balance
      max_balance
      balance_low_threshold
      balance_high_threshold
      send_balance_notifications_to
      destination_rate_limit
      max_call_duration
      vat
      origination_capacity
      termination_capacity
      total_capacity
      send_invoices_to

      contractor
      timezone
      invoice_period_id
      invoice_template
      external_id
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end

  def self.sortable_fields(context)
    super - %i[balance_low_threshold balance_high_threshold send_balance_notifications_to]
  end

  def self.required_model_includes(_context)
    [:balance_notification_setting]
  end
end
