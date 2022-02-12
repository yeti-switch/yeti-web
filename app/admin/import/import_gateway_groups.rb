# frozen_string_literal: true

ActiveAdmin.register Importing::GatewayGroup do
  filter :name
  contractor_filter :vendor_id_eq, label: 'Vendor', path_params: { q: { vendor_eq: true } }

  filter :balancing_mode, as: :select
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
    column :vendor, sortable: :vendor_name
    column :name
    column :balancing_mode, sortable: :balancing_mode_name
  end
end
