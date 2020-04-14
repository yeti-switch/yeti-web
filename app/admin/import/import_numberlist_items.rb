# frozen_string_literal: true

ActiveAdmin.register Importing::NumberlistItem, as: 'Numberlist Item Imports' do
  filter :key
  filter :numberlist, input_html: { class: 'chosen' }
  filter :action
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

    column :numberlist
    column :key
    column :number_min_length
    column :number_max_length
    column :action
    column :src_rewrite_rule
    column :src_rewrite_result
    column :dst_rewrite_rule
    column :dst_rewrite_result
    column :tag_action
    column :tag_action_value
    column :lua_script
  end
end
