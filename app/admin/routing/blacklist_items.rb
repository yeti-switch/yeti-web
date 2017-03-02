ActiveAdmin.register Routing::BlacklistItem do

#
#  menu parent: "Routing", priority: 120

  menu false
  #actions :index
  belongs_to :blacklist, parent_class: Routing::Blacklist

  navigation_menu :default
  config.batch_actions = true

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  controller do
    def permitted_params
      params.permit *active_admin_namespace.permitted_params, :blacklist_id,
                    active_admin_config.param_key => [
                        :key
                    ]
    end
  end


  sidebar :blacklist, priority: 1 do
    attributes_table_for assigns[:blacklist] do
      row :id
      row :name
      row :mode
      row :created_at
      row :updated_at
    end
  end

  index do
    selectable_column
    id_column
    actions
    column :key
    column :created_at
    column :updated_at
  end

  form do |f|
    f.inputs do
      f.input :key
    end
    f.actions
  end

  filter :id
  filter :key

end