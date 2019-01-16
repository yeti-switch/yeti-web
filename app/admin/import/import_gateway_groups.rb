ActiveAdmin.register Importing::GatewayGroup do

  filter :vendor, input_html: {class: 'chosen'}
  filter :name
  filter :prefer_same_pop, as: :select, collection: [["Yes", true], ["No", false]]

  acts_as_import_preview

  controller do
    def resource_params
      return [{}] if request.get?
      [ params[active_admin_config.resource_class.model_name.param_key.to_sym].permit! ]
    end
    def scoped_collection
      super.includes(:vendor)
    end
  end

  index do
    selectable_column
    actions
    id_column
    column :error_string
    column :o_id

    column :vendor, sortable: :vendor_name do |row|
      if row.vendor.blank?
        row.vendor_name
      else
        auto_link(row.vendor, row.vendor_name)
      end
    end

    column :name
    column :prefer_same_pop
  end
end
