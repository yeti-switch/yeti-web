# frozen_string_literal: true

ActiveAdmin.register Importing::Account do
  contractor_filter :contractor_id_eq

  filter :name
  filter :balance
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

    column :contractor, sortable: :contractor_name
    column :name
    column :balance
    column :vat
    column :min_balance
    column :max_balance
    column :destination_rate_limit
    column :origination_capacity
    column :termination_capacity
    column :total_capacity
  end
end
