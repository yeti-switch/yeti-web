# frozen_string_literal: true

ActiveAdmin.register Routing::Numberlist, as: 'Numberlist' do
  menu parent: 'Routing', priority: 110

  decorate_with NumberlistDecorator

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_async_destroy('Routing::Numberlist')
  acts_as_async_update BatchUpdateForm::NumberList

  acts_as_delayed_job_lock

  acts_as_export :id, :name,
                 [:mode_name, proc { |row| row.mode.name }],
                 [:default_action_name, proc { |row| row.default_action.name }],
                 :default_src_rewrite_rule, :default_src_rewrite_result,
                 :default_dst_rewrite_rule, :default_dst_rewrite_result,
                 [:tag_action_name, proc { |row| row.tag_action.try(:name) }],
                 [:tag_action_value_names, proc { |row| row.model.tag_action_values.map(&:name).join(', ') }],
                 [:lua_script_name, proc { |row| row.lua_script.try(:name) }],
                 :created_at, :updated_at

  acts_as_import resource_class: Importing::Numberlist,
                 skip_columns: [:tag_action_value]

  includes :mode, :default_action, :lua_script, :tag_action

  permit_params :name, :mode_id, :default_action_id,
                :default_src_rewrite_rule, :default_src_rewrite_result,
                :default_dst_rewrite_rule, :default_dst_rewrite_result,
                :tag_action_id, :lua_script_id, tag_action_value: []
  controller do
    def update
      if params['routing_numberlist']['tag_action_value'].nil?
        params['routing_numberlist']['tag_action_value'] = []
      end
      super
    end
  end

  index do
    selectable_column
    id_column
    actions
    column :name
    column :mode
    column :default_action
    column :default_src_rewrite_rule
    column :default_src_rewrite_result
    column :default_dst_rewrite_rule
    column :default_dst_rewrite_result
    column :lua_script
    column :tag_action
    column :display_tag_action_value
    column :created_at
    column :updated_at
    column 'External ID', :external_id, sortable: :external_id
  end

  show do |_s|
    attributes_table do
      row :id
      row :name
      row :mode
      row :default_action
      row :default_src_rewrite_rule
      row :default_src_rewrite_result
      row :default_dst_rewrite_rule
      row :default_dst_rewrite_result
      row :lua_script
      row :tag_action
      row :display_tag_action_value
      row :created_at
      row :updated_at
      row 'External ID', &:external_id
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :mode, as: :select, include_blank: false
      f.input :default_action, as: :select, include_blank: false
      f.input :default_src_rewrite_rule
      f.input :default_src_rewrite_result
      f.input :default_dst_rewrite_rule
      f.input :default_dst_rewrite_result
      f.input :lua_script, input_html: { class: 'chosen' }, include_blank: 'None'
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
  filter :name
  filter :mode
  filter :default_action
  filter :lua_script, input_html: { class: 'chosen' }
  filter :external_id, label: 'External ID'
  filter :tag_action, input_html: { class: 'chosen' }, collection: proc { Routing::TagAction.pluck(:name, :id) }
end
