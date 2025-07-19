# frozen_string_literal: true

ActiveAdmin.register Importing::Numberlist, as: 'Numberlist Imports' do
  filter :name

  filter :mode_id_eq, label: 'Mode', as: :select, collection: Routing::Numberlist::MODES.invert
  filter :default_action_id_eq, label: 'Default action', as: :select, collection: Routing::Numberlist::DEFAULT_ACTIONS.invert

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

    column :name
    column :mode, &:mode_display_name
    column :default_action, &:default_action_display_name
    column :default_src_rewrite_rule
    column :default_src_rewrite_result
    column :default_dst_rewrite_rule
    column :default_dst_rewrite_result
    column :tag_action
    column :tag_action_value
    column :rewrite_ss_status, &:rewrite_ss_status_name
    column :lua_script
  end
end
