ActiveAdmin.register Routing::RoutingTagDetectionRule do

  menu parent: "Routing", priority: 254, label: "Routing Tags detection"

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  permit_params :src_area_id, :dst_area_id, :routing_tag_id

  includes :routing_tag, :src_area, :dst_area

  index do
    selectable_column
    id_column
    actions
    column :src_area
    column :dst_area
    column :routing_tag
  end

  show do |s|
    attributes_table do
      row :id
      row :src_area
      row :dst_area
      row :routing_tag
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :src_area, hint: I18n.t('hints.routing.routing_tag_detection_rules.src_area')
      f.input :dst_area, hint: I18n.t('hints.routing.routing_tag_detection_rules.dst_area')
      f.input :routing_tag, hint: I18n.t('hints.routing.routing_tag_detection_rules.routing_tag')
    end
    f.actions
  end

  filter :id
  filter :routing_tag, input_html: {class: 'chosen'}
  filter :src_area, input_html: {class: 'chosen'}
  filter :dst_area, input_html: {class: 'chosen'}

end