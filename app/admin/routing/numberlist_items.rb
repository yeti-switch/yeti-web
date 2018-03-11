ActiveAdmin.register Routing::NumberlistItem do
  menu parent: "Routing", priority: 125, label: 'Numberlist items'

  navigation_menu :default
  config.batch_actions = true

  decorate_with NumberlistItemDecorator

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  acts_as_export :id,
                 :key,
                 [:numberlist_name, proc { |row| row.numberlist.name }],
                 [:action_name, proc { |row| row.action.try(:name) }],
                 :src_rewrite_rule,
                 :src_rewrite_result,
                 :dst_rewrite_rule,
                 :dst_rewrite_result,
                 [:tag_action_name, proc { |row| row.tag_action.try(:name) }],
                 [:tag_action_value_names, proc { |row| row.model.tag_action_values.map(&:name).join(', ') }],
                 :created_at, :updated_at

  includes :numberlist, :action

  permit_params :numberlist_id, :key, :action_id,
                :src_rewrite_rule, :src_rewrite_result,
                :dst_rewrite_rule, :dst_rewrite_result,
                :tag_action_id, tag_action_value: []

  filter :id
  filter :numberlist, input_html: {class: 'chosen'}
  filter :key

  controller do
    def update
      if params['routing_numberlist_item']['tag_action_value'].nil?
        params['routing_numberlist_item']['tag_action_value'] = []
      end
      super
    end
  end

  index do
    selectable_column
    id_column
    actions
    column :numberlist
    column :key
    column :action do |c|
      c.action.blank? ? 'Default action' : c.action.name
    end
    column :src_rewrite_rule
    column :src_rewrite_result
    column :dst_rewrite_rule
    column :dst_rewrite_result
    column :created_at
    column :updated_at
    column :tag_action
    column :display_tag_action_value
  end

  show do |s|
    attributes_table do
      row :id
      row :numberlist
      row :key
      row :action
      row :src_rewrite_rule
      row :src_rewrite_result
      row :dst_rewrite_rule
      row :dst_rewrite_result
      row :created_at
      row :updated_at
      row :tag_action
      row :display_tag_action_value
    end
  end

  form do |f|
    f.inputs do
      f.input :numberlist, input_html: {class: 'chosen'}
      f.input :key
      f.input :action, as: :select, include_blank: 'Default action'
      f.input :src_rewrite_rule
      f.input :src_rewrite_result
      f.input :dst_rewrite_rule
      f.input :dst_rewrite_result

      f.input :tag_action
      f.input :tag_action_value, as: :select,
        collection: Routing::RoutingTag.all,
        multiple: true,
        include_hidden: false,
        input_html: { class: 'chosen' }
    end
    f.actions
  end


end
