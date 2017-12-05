class Api::Rest::Admin::CustomersAuthResource < JSONAPI::Resource
  attributes :name, :ip, :enabled, :src_rewrite_rule, :src_rewrite_result, :dst_rewrite_rule, :dst_rewrite_result,
             :src_prefix, :dst_prefix, :x_yeti_auth, :capacity, :uri_domain,
             :src_name_rewrite_rule, :src_name_rewrite_result, :diversion_rewrite_rule, :diversion_rewrite_result,
             :allow_receive_rate_limit, :send_billing_information, :enable_audio_recording, :src_number_radius_rewrite_rule,
             :src_number_radius_rewrite_result, :dst_number_radius_rewrite_rule, :dst_number_radius_rewrite_result,
             :from_domain, :to_domain

  has_one :customer
  has_one :rateplan
  has_one :routing_plan, class_name: 'RoutingPlan'
  has_one :gateway
  has_one :account
  has_one :dump_level
  has_one :diversion_policy
  has_one :pop
  has_one :dst_numberlist, class_name: 'Routing::Numberlist'
  has_one :src_numberlist, class_name: 'Routing::Numberlist'
  has_one :radius_auth_profile, class_name: 'Equipment::Radius::AuthProfile'
  has_one :radius_accounting_profile, class_name: 'Equipment::Radius::AccountingProfile'
  has_one :transport_protocol, class_name: 'Equipment::TransportProtocol'

  filter :name

  def self.updatable_fields(context)
    [
      :name,
      :customer,
      :rateplan,
      :enabled,
      :ip,
      :account,
      :gateway,
      :src_rewrite_rule,
      :src_rewrite_result,
      :dst_rewrite_rule,
      :dst_rewrite_result,
      :src_prefix,
      :dst_prefix,
      :x_yeti_auth,
      :name,
      :dump_level,
      :capacity,
      :pop,
      :uri_domain,
      :src_name_rewrite_rule,
      :src_name_rewrite_result,
      :diversion_policy,
      :diversion_rewrite_rule,
      :diversion_rewrite_result,
      :dst_numberlist,
      :src_numberlist,
      :routing_plan,
      :allow_receive_rate_limit,
      :send_billing_information,
      :radius_auth_profile,
      :enable_audio_recording,
      :src_number_radius_rewrite_rule,
      :src_number_radius_rewrite_result,
      :dst_number_radius_rewrite_rule,
      :dst_number_radius_rewrite_result,
      :radius_accounting_profile,
      :from_domain,
      :to_domain,
      :transport_protocol
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
