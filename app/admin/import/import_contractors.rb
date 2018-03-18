ActiveAdmin.register Importing::Contractor do


  filter :name
  filter :enabled, as: :select, collection: [["Yes", true], ["No", false]]
  filter :vendor, as: :select, collection: [["Yes", true], ["No", false]]
  filter :customer, as: :select, collection: [["Yes", true], ["No", false]]

  acts_as_import_preview

  controller do
    def resource_params
      return [] if request.get?
      [ params[active_admin_config.resource_class.model_name.param_key.to_sym].permit! ]
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
    column :vendor
    column :customer
    column :smtp_connection, sortable: :smtp_connection_name do |row|
      if row.smtp_connection.blank?
        row.smtp_connection_name
      else
        auto_link(row.smtp_connection, row.smtp_connection_name)
      end
    end
  end

end
