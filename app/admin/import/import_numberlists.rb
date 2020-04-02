# frozen_string_literal: true

ActiveAdmin.register Importing::Numberlist, as: 'Numberlist Imports' do
  filter :name
  filter :mode
  filter :default_action
  boolean_filter :is_changed

  acts_as_import_preview

  controller do
    def resource_params
      return [{}] if request.get?

      [params[active_admin_config.resource_class.model_name.param_key.to_sym].permit!]
    end
  end

  includes :mode, :default_action, :lua_script

  index do
    selectable_column
    actions
    id_column

    column :error_string
    column :o_id
    column :is_changed

    column :name
    column :mode
    column :default_action
    column :default_src_rewrite_rule
    column :default_src_rewrite_result
    column :default_dst_rewrite_rule
    column :default_dst_rewrite_result
    column :tag_action
    column :tag_action_value do |row|
      if row.tag_action_value.present?
        Routing::RoutingTag.where(id: row.tag_action_value).pluck(:name).join(', ')
      end
    end
    column :lua_script
  end
end
