ActiveAdmin.register Routing::RoutingTagDetectionRule do

  menu parent: "Routing", priority: 254, label: "Routing Tags detection"

  decorate_with RoutingTagDetectionRuleDecorator

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  acts_as_export :id,
                 [:routing_tag_names, proc { |row| row.model.routing_tags.map(&:name).join(', ') }],
                 [:src_area_name, proc { |row| row.src_area.try(:name) } ],
                 [:dst_area_name, proc { |row| row.dst_area.try(:name) } ],
                 [:tag_action_name, proc { |row| row.tag_action.try(:name) }],
                 [:tag_action_value_names, proc { |row| row.model.tag_action_values.map(&:name).join(', ') }]

  permit_params :src_area_id, :dst_area_id,
                :tag_action_id, tag_action_value: [],
                routing_tag_ids: []

  includes :src_area, :dst_area, :tag_action

  controller do
    def update
      if params['routing_routing_tag_detection_rule']['tag_action_value'].nil?
        params['routing_routing_tag_detection_rule']['tag_action_value'] = []
      end
      if params['routing_routing_tag_detection_rule']['routing_tag_ids'].nil?
        params['routing_routing_tag_detection_rule']['routing_tag_ids'] = []
      end
      super
    end
  end

  index do
    selectable_column
    id_column
    actions
    column :routing_tags
    column :src_area
    column :dst_area
    column :tag_action
    column :display_tag_action_value
  end

  show do |s|
    attributes_table do
      row :id
      row :routing_tags
      row :src_area
      row :dst_area
      row :tag_action
      row :display_tag_action_value
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :routing_tag_ids, as: :select,
        collection: RoutingTagDetectionRuleDecorator.decorate(f.object).routing_tag_options,
        multiple: true,
        include_hidden: false,
        input_html: { class: 'chosen' }
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
