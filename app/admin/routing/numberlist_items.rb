# frozen_string_literal: true

ActiveAdmin.register Routing::NumberlistItem do
  menu parent: 'Routing', priority: 125, label: 'Numberlist items'

  config.batch_actions = true

  decorate_with NumberlistItemDecorator

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  acts_as_export :id,
                 :key,
                 :number_min_length,
                 :number_max_length,
                 [:numberlist_name, proc { |row| row.numberlist.name }],
                 [:action_name, proc { |row| row.action.try(:name) }],
                 :src_rewrite_rule,
                 :src_rewrite_result,
                 :dst_rewrite_rule,
                 :dst_rewrite_result,
                 [:tag_action_name, proc { |row| row.tag_action.try(:name) }],
                 [:tag_action_value_names, proc { |row| row.model.tag_action_values.map(&:name).join(', ') }],
                 [:lua_script_name, proc { |row| row.lua_script.try(:name) }],
                 :created_at,
                 :updated_at

  acts_as_import resource_class: Importing::NumberlistItem,
                 skip_columns: [:tag_action_value]

  includes :numberlist, :action, :lua_script, :tag_action

  permit_params :numberlist_id,
                :key, :number_min_length, :number_max_length,
                :action_id,
                :src_rewrite_rule, :src_rewrite_result,
                :dst_rewrite_rule, :dst_rewrite_result,
                :tag_action_id, :lua_script_id, tag_action_value: []

  filter :id
  filter :numberlist, input_html: { class: 'chosen' }
  filter :key
  filter :lua_script, input_html: { class: 'chosen' }
  filter :action, input_html: { class: 'chosen' }, collection: proc { Routing::NumberlistAction.pluck(:name, :id) }
  filter :tag_action, input_html: { class: 'chosen' }, collection: proc { Routing::TagAction.pluck(:name, :id) }
  filter :created_at, as: :date_time_range
  filter :updated_at, as: :date_time_range

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
    column :number_length do |c|
      c.number_min_length == c.number_max_length ? c.number_min_length.to_s : "#{c.number_min_length}..#{c.number_max_length}"
    end
    column :action do |c|
      c.action.blank? ? 'Default action' : c.action.name
    end
    column :src_rewrite_rule
    column :src_rewrite_result
    column :dst_rewrite_rule
    column :dst_rewrite_result
    column :tag_action
    column :display_tag_action_value
    column :lua_script
    column :created_at
    column :updated_at
  end

  show do |_s|
    tabs do
      tab :general do
        attributes_table do
          row :id
          row :numberlist
          row :key
          row :number_min_length
          row :number_max_length
          row :action
          row :src_rewrite_rule
          row :src_rewrite_result
          row :dst_rewrite_rule
          row :dst_rewrite_result
          row :tag_action
          row :display_tag_action_value
          row :lua_script
          row :created_at
          row :updated_at
        end
      end
      tab :comments do
        active_admin_comments
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :numberlist, input_html: { class: 'chosen' }
      f.input :key
      f.input :number_min_length
      f.input :number_max_length
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
      f.input :lua_script, as: :select, input_html: { class: 'chosen' }, include_blank: 'None'
    end
    f.actions
  end
end
