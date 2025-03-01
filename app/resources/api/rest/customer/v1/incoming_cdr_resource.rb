# frozen_string_literal: true

class Api::Rest::Customer::V1::IncomingCdrResource < Api::Rest::Customer::V1::BaseResource
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
             :dialpeer_initial_interval,
             :dialpeer_initial_rate,
             :dialpeer_next_interval,
             :dialpeer_next_rate,
             :dialpeer_fee,
             :dialpeer_prefix,
             :vendor_price,
             :vendor_duration,
             :src_name_out,
             :src_prefix_out,
             :dst_prefix_out,
             :src_prefix_routing,
             :dst_prefix_routing,
             :diversion_out,
             :local_tag,
             :legb_disconnect_code,
             :legb_disconnect_reason,
             :sign_term_ip,
             :sign_term_port,
             :sign_term_transport_protocol_id,
             :term_call_id,
             :legb_user_agent,
             :rec

  has_one :account, class_name: 'Account', relation_name: :vendor_acc, foreign_key_on: :related

  ransack_filter :id, type: :number
  ransack_filter :time_start, type: :datetime
  ransack_filter :time_connect, type: :datetime
  ransack_filter :time_end, type: :datetime
  ransack_filter :duration, type: :number
  ransack_filter :success, type: :boolean

  ransack_filter :dialpeer_initial_rate, type: :number
  ransack_filter :dialpeer_next_rate, type: :number
  ransack_filter :dialpeer_initial_interval, type: :number
  ransack_filter :dialpeer_next_interval, type: :number
  ransack_filter :dialpeer_fee, type: :number
  ransack_filter :dialpeer_reverse_billing, type: :boolean
  ransack_filter :dialpeer_prefix, type: :string
  ransack_filter :vendor_price, type: :number
  ransack_filter :vendor_duration, type: :number

  ransack_filter :src_name_out, type: :string
  ransack_filter :dst_prefix_out, type: :string
  ransack_filter :src_prefix_out, type: :string
  ransack_filter :src_prefix_routing, type: :string
  ransack_filter :dst_prefix_routing, type: :string
  ransack_filter :diversion_out, type: :string

  ransack_filter :local_tag, type: :string
  ransack_filter :legb_disconnect_code, type: :number
  ransack_filter :legb_disconnect_reason, type: :string

  ransack_filter :sign_term_ip, type: :string
  ransack_filter :sign_term_port, type: :number
  ransack_filter :sign_term_transport_protocol_id, type: :number
  ransack_filter :term_call_id, type: :string
  ransack_filter :legb_user_agent, type: :string

  association_uuid_filter :account_id, column: :vendor_acc_id, class_name: 'Account'

  def rec
    return false unless context[:current_customer].allow_listen_recording

    _model.has_recording?
  end

  def fetchable_fields
    fields = super
    hidden_fields = YetiConfig.customer_api_incoming_cdr_hide_fields || []
    fields - hidden_fields.map(&:to_sym)
  end

  def self.apply_allowed_accounts(records, options)
    context = options[:context]
    scope = records.where_vendor(context[:customer_id])
    scope = scope.where_vendor_account(context[:allowed_account_ids]) if context[:allowed_account_ids].present?
    scope
  end

  def self.apply_default_filter_time_start_gteq(options)
    return nil if options.dig(:params, :filter, :time_start_gt).present?
    return nil if options.dig(:params, :filter, :time_start_eq).present?

    24.hours.ago.strftime('%F %T')
  end
end
