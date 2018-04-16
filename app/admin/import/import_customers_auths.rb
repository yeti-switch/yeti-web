ActiveAdmin.register Importing::CustomersAuth do

  filter :customer_name
  filter :rateplan_name
  filter :routing_plan_name
  filter :gateway_name
  filter :account_name

  acts_as_import_preview

  controller do
    def resource_params
      return [] if request.get?
      [ params[active_admin_config.resource_class.model_name.param_key.to_sym].permit! ]
    end
    def scoped_collection
      super.includes(:rateplan, :routing_plan, :gateway, :account, :customer, :diversion_policy, :dump_level)
    end
  end


  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :name
    column :enabled
    column :reject_calls
    column :transport_protocol, sortable: :transport_protocol_name do |row|
      if row.transport_protocol.blank?
        row.transport_protocol_name
      else
        auto_link(row.transport_protocol, row.transport_protocol_name)
      end
    end
    column :ip

    column :pop, sortable: :pop_name do |row|
      if row.pop.blank?
        row.pop_name
      else
        auto_link(row.pop, row.pop_name)
      end
    end

    column :src_prefix
    column :dst_prefix
    column :dst_number_length do |c|
      c.dst_number_min_length==c.dst_number_max_length ? "#{c.dst_number_min_length}" : "#{c.dst_number_min_length}..#{c.dst_number_max_length}"
    end
    column :uri_domain
    column :from_domain
    column :to_domain
    column :x_yeti_auth

    column :customer, sortable: :customer_name do |row|
      if row.customer.blank?
        row.customer_name
      else
        auto_link(row.customer, row.customer_name)
      end
    end

    column :account, sortable: :account_name do |row|
      if row.account.blank?
        row.account_name
      else
        auto_link(row.account, row.account_name)
      end
    end

    column :check_account_balance

    column :gateway, sortable: :gateway_name do |row|
      if row.gateway.blank?
        row.gateway_name
      else
        auto_link(row.gateway, row.gateway_name)
      end
    end

    column :require_sip_auth

    column :rateplan, sortable: :rateplan_name do |row|
      if row.rateplan.blank?
        row.rateplan_name
      else
        auto_link(row.rateplan, row.rateplan_name)
      end
    end

    column :routing_plan, sortable: :routing_plan_name do |row|
      if row.routing_plan.blank?
        row.routing_plan_name
      else
        auto_link(row.routing_plan, row.routing_plan_name)
      end
    end

    column :dst_numberlist, sortable: :dst_numberlist_name do |row|
      if row.dst_numberlist.blank?
        row.dst_numberlist_name
      else
        auto_link(row.dst_numberlist, row.dst_numberlist_name)
      end
    end

    column :src_numberlist, sortable: :src_numberlist_name do |row|
      if row.src_numberlist.blank?
        row.src_numberlist_name
      else
        auto_link(row.src_numberlist, row.src_numberlist_name)
      end
    end

    column :dump_level, sortable: :dump_level_name do |row|
      if row.dump_level.blank?
        row.dump_level_name
      else
        auto_link(row.dump_level, row.dump_level_name)
      end
    end

    column :enable_audio_recording
    column :capacity
    column :allow_receive_rate_limit
    column :send_billing_information

    column :diversion_policy, sortable: :diversion_policy_name do |row|
      if row.diversion_policy.blank?
        row.diversion_policy_name
      else
        auto_link(row.diversion_policy, row.diversion_policy_name)
      end
    end

    column :diversion_rewrite_rule
    column :diversion_rewrite_result
    column :src_rewrite_rule
    column :src_rewrite_result
    column :dst_rewrite_rule
    column :dst_rewrite_result

    column :radius_auth_profile, sortable: :radius_auth_profile_name do |row|
      if row.radius_auth_profile.blank?
        row.radius_auth_profile_name
      else
        auto_link(row.radius_auth_profile, row.radius_auth_profile_name)
      end
    end
    column :src_number_radius_rewrite_rule
    column :src_number_radius_rewrite_result
    column :dst_number_radius_rewrite_rule
    column :dst_number_radius_rewrite_result
    column :radius_accounting_profile, sortable: :radius_accounting_profile_name do |row|
      if row.radius_accounting_profile.blank?
        row.radius_accounting_profile_name
      else
        auto_link(row.radius_accounting_profile, row.radius_accounting_profile_name)
      end
    end

    column :tag_action
    column :tag_action_value do |row|
      if row.tag_action_value.present?
        Routing::RoutingTag.where(id: row.tag_action_value).pluck(:name).join(', ')
      else
        row.tag_action_value_names
      end
    end
  end

end
