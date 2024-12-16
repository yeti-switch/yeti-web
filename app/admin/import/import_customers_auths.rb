# frozen_string_literal: true

ActiveAdmin.register Importing::CustomersAuth do
  filter :customer_name
  filter :rateplan_name
  filter :routing_plan_name
  filter :gateway_name
  filter :account_name
  boolean_filter :is_changed

  decorate_with Importing::CustomersAuthDecorator

  acts_as_import_preview

  controller do
    def resource_params
      return [{}] if request.get?

      [params[active_admin_config.resource_class.model_name.param_key.to_sym].permit!]
    end
  end

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :is_changed

    column :name
    column :enabled
    column :reject_calls
    column :transport_protocol, &:transport_protocol_display_name
    column :ip
    column :pop, sortable: :pop_name
    column :src_prefix
    column :src_number_min_length
    column :src_number_max_length

    column :dst_prefix
    column :dst_number_min_length
    column :dst_number_max_length

    column :uri_domain
    column :from_domain
    column :to_domain

    column :x_yeti_auth

    column :customer, sortable: :customer_name
    column :account, sortable: :account_name
    column :check_account_balance
    column :gateway, sortable: :gateway_name
    column :require_sip_auth
    column :rateplan, sortable: :rateplan_name
    column :routing_plan, sortable: :routing_plan_name
    column :dst_numberlist, sortable: :dst_numberlist_name
    column :src_numberlist, sortable: :src_numberlist_name
    column :dump_level, &:dump_level_display_name
    column :privacy_mode_id, &:privacy_mode_name

    column :enable_audio_recording
    column :capacity
    column :cps_limit
    column :allow_receive_rate_limit
    column :send_billing_information

    column :diversion_policy, &:diversion_policy_display_name
    column :diversion_rewrite_rule
    column :diversion_rewrite_result

    column :pai_policy, &:pai_policy_display_name

    column :src_rewrite_rule
    column :src_rewrite_result
    column :dst_rewrite_rule
    column :dst_rewrite_result

    column :lua_script
    column :radius_auth_profile, sortable: :radius_auth_profile_name

    column :src_number_radius_rewrite_rule
    column :src_number_radius_rewrite_result
    column :dst_number_radius_rewrite_rule
    column :dst_number_radius_rewrite_result

    column :radius_accounting_profile, sortable: :radius_accounting_profile_name

    column :tag_action
    column :tag_action_value
  end
end
