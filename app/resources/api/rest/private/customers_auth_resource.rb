class Api::Rest::Private::CustomersAuthResource < JSONAPI::Resource
  attributes :name, :ip, :customer_id, :rateplan_id, :routing_plan_id, :gateway_id, :account_id, :dump_level_id,
             :diversion_policy_id,
             :enabled, :src_rewrite_rule, :src_rewrite_result, :dst_rewrite_rule, :dst_rewrite_result,
             :src_prefix, :dst_prefix, :x_yeti_auth, :capacity, :pop_id, :uri_domain,
             :src_name_rewrite_rule, :src_name_rewrite_result, :diversion_rewrite_rule, :diversion_rewrite_result,
             :dst_numberlist_id, :src_numberlist_id, :allow_receive_rate_limit, :send_billing_information,
             :radius_auth_profile_id, :enable_audio_recording, :src_number_radius_rewrite_rule,
             :src_number_radius_rewrite_result, :dst_number_radius_rewrite_rule, :dst_number_radius_rewrite_result,
             :radius_accounting_profile_id, :from_domain, :to_domain, :transport_protocol_id

  def self.updatable_fields(context)
    [
      :name,
      :customer_id,
      :rateplan_id,
      :enabled,
      :ip,
      :account_id,
      :gateway_id,
      :src_rewrite_rule,
      :src_rewrite_result,
      :dst_rewrite_rule,
      :dst_rewrite_result,
      :src_prefix,
      :dst_prefix,
      :x_yeti_auth,
      :name,
      :dump_level_id,
      :capacity,
      :pop_id,
      :uri_domain,
      :src_name_rewrite_rule,
      :src_name_rewrite_result,
      :diversion_policy_id,
      :diversion_rewrite_rule,
      :diversion_rewrite_result,
      :dst_numberlist_id,
      :src_numberlist_id,
      :routing_plan_id,
      :allow_receive_rate_limit,
      :send_billing_information,
      :radius_auth_profile_id,
      :enable_audio_recording,
      :src_number_radius_rewrite_rule,
      :src_number_radius_rewrite_result,
      :dst_number_radius_rewrite_rule,
      :dst_number_radius_rewrite_result,
      :radius_accounting_profile_id,
      :from_domain,
      :to_domain,
      :transport_protocol_id
    ]
  end

  def self.creatable_fields(context)
    self.updatable_fields(context)
  end
end
