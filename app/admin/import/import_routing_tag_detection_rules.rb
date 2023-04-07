# frozen_string_literal: true

ActiveAdmin.register Importing::RoutingTagDetectionRule, as: 'Routing Tag Detection Rule Imports' do
  filter :o_id
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

    column 'Routing Tags', &:routing_tag_ids
    column :src_area
    column :dst_area
    column :src_prefix
    column :dst_prefix
    column :tag_action
    column :tag_action_value
  end
end
