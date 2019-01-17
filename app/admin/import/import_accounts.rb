ActiveAdmin.register Importing::Account do

  filter :contractor, input_html: {class: 'chosen'}
  filter :name
  filter :balance

  acts_as_import_preview

  controller do
    def resource_params
      return [{}] if request.get?
      [params[active_admin_config.resource_class.model_name.param_key.to_sym].permit!]
    end

    def scoped_collection
      super.includes(:contractor)
    end
  end

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id
    column :contractor, sortable: :contractor_name do |row|
      if row.contractor.blank?
        row.contractor_name
      else
        auto_link(row.contractor, row.contractor_name)
      end
    end

    column :name
    column :balance
    column :vat
    column :min_balance
    column :max_balance
    column :balance_low_threshold
    column :balance_high_threshold
    column :destination_rate_limit

    column :origination_capacity
    column :termination_capacity
    column :total_capacity
  end

end
