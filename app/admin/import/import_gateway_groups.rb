# frozen_string_literal: true

ActiveAdmin.register Importing::GatewayGroup do
  acts_as_import_preview

  controller do
    def resource_params
      return [{}] if request.get?

      [params[active_admin_config.resource_class.model_name.param_key.to_sym].permit!]
    end
  end

  filter :name
  contractor_filter :vendor_id_eq, label: 'Vendor', path_params: { q: { vendor_eq: true } }
  filter :max_rerouting_attempts
  boolean_filter :is_changed

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :is_changed
    column :vendor, sortable: :vendor_name
    column :name
    column :balancing_mode, &:balancing_mode_display_name
    column :max_rerouting_attempts
  end
end
