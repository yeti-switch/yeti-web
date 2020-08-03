# frozen_string_literal: true

ActiveAdmin.register Importing::Registration do
  filter :customer_name
  filter :rateplan_name
  filter :routing_group_name
  filter :gateway_name
  filter :account_name
  boolean_filter :is_changed

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
    column :pop, sortable: :pop_name
    column :node, sortable: :node_name
    column :sip_schema, sortable: :sip_schema_name
    column :transport_protocol, sortable: :transport_protocol_name
    column :domain
    column :username
    column :display_username
    column :auth_user
    column :auth_password
    column :proxy
    column :proxy_transport_protocol, sortable: :proxy_transport_protocol_name
    column :contact
    column :expire
    column :force_expire
    column :retry_delay
    column :max_attempts
  end
end
