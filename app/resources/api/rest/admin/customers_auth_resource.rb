# frozen_string_literal: true

class Api::Rest::Admin::CustomersAuthResource < BaseResource
  attributes :name, :ip, :enabled, :reject_calls, :src_rewrite_rule, :src_rewrite_result, :dst_rewrite_rule, :dst_rewrite_result,
             :src_prefix, :src_number_min_length, :src_number_max_length,
             :dst_prefix, :dst_number_min_length, :dst_number_max_length,
             :x_yeti_auth, :capacity, :cps_limit, :uri_domain,
             :src_name_rewrite_rule, :src_name_rewrite_result, :diversion_rewrite_rule, :diversion_rewrite_result,
             :allow_receive_rate_limit, :send_billing_information, :enable_audio_recording, :src_number_radius_rewrite_rule,
             :src_number_radius_rewrite_result, :dst_number_radius_rewrite_rule, :dst_number_radius_rewrite_result,
             :check_account_balance, :require_incoming_auth,
             :from_domain, :to_domain, :tag_action_value, :external_id, :external_type, :dump_level_id

  paginator :paged

  has_one :customer, always_include_linkage_data: true
  has_one :rateplan, class_name: 'Rateplan', always_include_linkage_data: true
  has_one :routing_plan, class_name: 'RoutingPlan', always_include_linkage_data: true
  has_one :gateway, always_include_linkage_data: true
  has_one :account, always_include_linkage_data: true
  has_one :diversion_policy, always_include_linkage_data: true
  has_one :pop, always_include_linkage_data: true
  has_one :dst_numberlist, class_name: 'Numberlist', always_include_linkage_data: true
  has_one :src_numberlist, class_name: 'Numberlist', always_include_linkage_data: true
  has_one :tag_action, class_name: 'TagAction', always_include_linkage_data: true
  has_one :radius_auth_profile, class_name: 'RadiusAuthProfile', always_include_linkage_data: true
  has_one :radius_accounting_profile, class_name: 'RadiusAccountingProfile', always_include_linkage_data: true
  has_one :transport_protocol, class_name: 'TransportProtocol', always_include_linkage_data: true

  filter :name

  relationship_filter :customer
  relationship_filter :rateplan
  relationship_filter :routing_plan
  relationship_filter :gateway
  relationship_filter :account
  relationship_filter :diversion_policy
  relationship_filter :pop
  relationship_filter :dst_numberlist
  relationship_filter :src_numberlist
  relationship_filter :tag_action
  relationship_filter :radius_auth_profile
  relationship_filter :radius_accounting_profile
  relationship_filter :transport_protocol

  ransack_filter :name, type: :string
  ransack_filter :enabled, type: :boolean
  ransack_filter :reject_calls, type: :boolean
  ransack_filter :src_rewrite_rule, type: :string
  ransack_filter :src_rewrite_result, type: :string
  ransack_filter :dst_rewrite_rule, type: :string
  ransack_filter :dst_rewrite_result, type: :string
  ransack_filter :src_prefix, type: :string
  ransack_filter :src_number_min_length, type: :number
  ransack_filter :src_number_max_length, type: :number
  ransack_filter :dst_prefix, type: :string
  ransack_filter :dst_number_min_length, type: :number
  ransack_filter :dst_number_max_length, type: :number
  ransack_filter :x_yeti_auth, type: :string
  ransack_filter :capacity, type: :number
  ransack_filter :cps_limit, type: :number
  ransack_filter :uri_domain, type: :string
  ransack_filter :src_name_rewrite_rule, type: :string
  ransack_filter :src_name_rewrite_result, type: :string
  ransack_filter :diversion_rewrite_rule, type: :string
  ransack_filter :diversion_rewrite_result, type: :string
  ransack_filter :allow_receive_rate_limit, type: :boolean
  ransack_filter :send_billing_information, type: :boolean
  ransack_filter :enable_audio_recording, type: :boolean
  ransack_filter :src_number_radius_rewrite_rule, type: :string
  ransack_filter :src_number_radius_rewrite_result, type: :string
  ransack_filter :dst_number_radius_rewrite_rule, type: :string
  ransack_filter :dst_number_radius_rewrite_result, type: :string
  ransack_filter :check_account_balance, type: :boolean
  ransack_filter :require_incoming_auth, type: :boolean
  ransack_filter :from_domain, type: :string
  ransack_filter :to_domain, type: :string
  ransack_filter :tag_action_value, type: :number
  ransack_filter :external_id, type: :number
  ransack_filter :external_type, type: :string
  ransack_filter :dump_level_id, type: :number

  def self.updatable_fields(_context)
    %i[
      name
      customer
      rateplan
      enabled
      reject_calls
      ip
      account
      gateway
      src_rewrite_rule
      src_rewrite_result
      dst_rewrite_rule
      dst_rewrite_result
      src_prefix
      src_number_min_length
      src_number_max_length
      dst_prefix
      dst_number_min_length
      dst_number_max_length
      x_yeti_auth
      tag_action_value
      dump_level_id
      capacity
      cps_limit
      pop
      uri_domain
      src_name_rewrite_rule
      src_name_rewrite_result
      diversion_policy
      diversion_rewrite_rule
      diversion_rewrite_result
      dst_numberlist
      src_numberlist
      tag_action
      routing_plan
      allow_receive_rate_limit
      send_billing_information
      radius_auth_profile
      enable_audio_recording
      src_number_radius_rewrite_rule
      src_number_radius_rewrite_result
      dst_number_radius_rewrite_rule
      dst_number_radius_rewrite_result
      check_account_balance
      require_incoming_auth
      radius_accounting_profile
      from_domain
      to_domain
      transport_protocol
      external_id
      external_type
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
