ActiveAdmin.register Routing::NumberlistItem do

#
#  menu parent: "Routing", priority: 120

  menu false
  #actions :index
  belongs_to :numberlist, parent_class: Routing::Numberlist

  navigation_menu :default
  config.batch_actions = true

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  controller do
    def permitted_params
      params.permit *active_admin_namespace.permitted_params, :numberlist_id,
                    active_admin_config.param_key => [
                        :key,
                        :action_id
                    ]
    end
  end


  sidebar :numberlist, priority: 1 do
    attributes_table_for assigns[:numberlist] do
      row :id
      row :name
      row :mode
      row :default_action
      row :created_at
      row :updated_at
    end
  end

  index do
    selectable_column
    id_column
    actions
    column :key
    column :action do |c|
      c.action.blank? ? 'Default action' : c.action.name
    end
    column :created_at
    column :updated_at
  end

  form do |f|
    f.inputs do
      f.input :key
      f.input :action, as: :select, include_blank: 'Default action'
    end
    f.actions
  end

  filter :id
  filter :key

end