ActiveAdmin.register Importing::Registration do

  filter :customer_name
  filter :rateplan_name
  filter :routing_group_name
  filter :gateway_name
  filter :account_name

  acts_as_import_preview

  controller do
    def resource_params
      return [] if request.get?
      [ params[active_admin_config.resource_class.model_name.param_key.to_sym].permit! ]
    end
    def scoped_collection
      super.includes(:pop, :node)
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

    column :pop, sortable: :pop_name do |row|
      if row.pop.blank?
        row.pop_name
      else
        auto_link(row.pop, row.pop_name)
      end
    end

    column :node, sortable: :node_name do |row|
      if row.node.blank?
        row.node_name
      else
        auto_link(row.node, row.node_name)
      end
    end

    column :domain
    column :username
    column :display_username
    column :auth_user
    column :auth_password
    column :proxy
    column :contact
    column :expire
    column :force_expire
    column :retry_delay
    column :max_attempts
  end

end
