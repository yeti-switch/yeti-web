# frozen_string_literal: true

class Api::Rest::Customer::V1::CdrResource < Api::Rest::Customer::V1::BaseResource
  model_name 'Cdr::Cdr'

  key_type :integer
  primary_key :id

  def self.default_sort
    [{ field: 'time_start', direction: :desc }]
  end

  attributes :time_start,
             :time_connect,
             :time_end,
             :duration,
             :success,
             :destination_initial_interval,
             :destination_initial_rate,
             :destination_next_interval,
             :destination_next_rate,
             :destination_fee,
             :customer_price,
             :customer_duration,
             :src_name_in,
             :src_prefix_in,
             :from_domain,
             :dst_prefix_in,
             :to_domain,
             :ruri_domain,
             :diversion_in,
             :local_tag,
             :lega_disconnect_code,
             :lega_disconnect_reason,
             :auth_orig_transport_protocol_id,
             :auth_orig_ip,
             :auth_orig_port,
             :src_prefix_routing,
             :dst_prefix_routing,
             :destination_prefix,
             :orig_call_id,
             :lega_user_agent,
             :rec

  has_one :auth_orig_transport_protocol, class_name: 'TransportProtocol'
  has_one :account, class_name: 'Account', relation_name: :customer_acc, foreign_key_on: :related

  ransack_filter :id, type: :number
  ransack_filter :time_start, type: :datetime, default: { gteq: :apply_default_filter_time_start_gteq }
  ransack_filter :time_connect, type: :datetime
  ransack_filter :time_end, type: :datetime
  ransack_filter :duration, type: :number
  ransack_filter :success, type: :boolean

  ransack_filter :destination_prefix, type: :string
  ransack_filter :destination_initial_rate, type: :number
  ransack_filter :destination_next_rate, type: :number
  ransack_filter :destination_fee, type: :number
  ransack_filter :destination_initial_interval, type: :number
  ransack_filter :destination_next_interval, type: :number
  ransack_filter :destination_reverse_billing, type: :boolean

  ransack_filter :customer_acc_vat, type: :number
  ransack_filter :customer_price, type: :number
  ransack_filter :customer_price_no_vat, type: :number
  ransack_filter :customer_duration, type: :number

  ransack_filter :dst_prefix_in, type: :string
  ransack_filter :src_prefix_in, type: :string
  ransack_filter :src_name_in, type: :string
  ransack_filter :src_prefix_routing, type: :string
  ransack_filter :dst_prefix_routing, type: :string
  ransack_filter :diversion_in, type: :string

  ransack_filter :orig_call_id, type: :string
  ransack_filter :local_tag, type: :string

  ransack_filter :lega_disconnect_code, type: :number
  ransack_filter :lega_disconnect_reason, type: :string

  ransack_filter :auth_orig_transport_protocol_id, type: :number
  ransack_filter :auth_orig_ip, type: :inet
  ransack_filter :auth_orig_port, type: :number

  ransack_filter :lega_user_agent, type: :string

  ransack_filter :pai_in, type: :string
  ransack_filter :ppi_in, type: :string
  ransack_filter :privacy_in, type: :string
  ransack_filter :rpid_in, type: :string
  ransack_filter :rpid_privacy_in, type: :string

  ransack_filter :ruri_domain, type: :string
  ransack_filter :to_domain, type: :string
  ransack_filter :from_domain, type: :string

  association_uuid_filter :account_id, column: :customer_acc_id, class_name: 'Account'

  def rec
    return false unless context[:current_customer].allow_listen_recording

    _model.has_recording?
  end

  def fetchable_fields
    fields = super
    hidden_fields = YetiConfig.customer_api_outgoing_cdr_hide_fields || []
    fields - hidden_fields.map(&:to_sym)
  end

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    scope = records.where_customer(context[:customer_id])
    scope = scope.where_customer_account(context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end

  def self.apply_default_filter_time_start_gteq(options)
    return nil if options.dig(:params, :filter, :time_start_gt).present?
    return nil if options.dig(:params, :filter, :time_start_eq).present?

    24.hours.ago.strftime('%F %T')
  end
end
