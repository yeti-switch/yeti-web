ActiveAdmin.register Routing::RoutingTagDetectionRule do

  menu parent: "Routing", priority: 254, label: "Routing Tags detection"

  decorate_with RoutingTagDetectionRuleDecorator

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  permit_params :src_area_id, :dst_area_id,
                :tag_action_id, tag_action_value: []

  includes :src_area, :dst_area

  controller do
    def update
      if params['routing_routing_tag_detection_rule']['tag_action_value'].nil?
        params['routing_routing_tag_detection_rule']['tag_action_value'] = []
      end
      super
    end
  end

  index do
    selectable_column
    id_column
    actions
    column :src_area
    column :dst_area
    column :tag_action
    column :routing_tags
  end

  show do |s|
    attributes_table do
      row :id
      row :src_area
      row :dst_area
      row :tag_action
      row :routing_tags
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :src_area
      f.input :dst_area
      f.input :tag_action
      f.input :tag_action_value, as: :select,
        collection: Routing::RoutingTag.all,
        multiple: true,
        include_hidden: false,
        input_html: { class: 'chosen' }
    end
    f.actions
  end

  filter :id
  filter :src_area, input_html: {class: 'chosen'}
  filter :dst_area, input_html: {class: 'chosen'}

end
