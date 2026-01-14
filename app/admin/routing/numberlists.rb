# frozen_string_literal: true

ActiveAdmin.register Routing::Numberlist, as: 'Numberlist' do
  menu parent: 'Routing', priority: 110

  decorate_with NumberlistDecorator

  search_support!
  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_async_destroy('Routing::Numberlist')
  acts_as_async_update BatchUpdateForm::NumberList

  acts_as_good_job_lock

  acts_as_export :id, :name,
                 :mode_name,
                 :default_action_name,
                 :default_src_rewrite_rule, :default_src_rewrite_result, :defer_src_rewrite,
                 :default_dst_rewrite_rule, :default_dst_rewrite_result, :defer_dst_rewrite,
                 [:tag_action_name, proc { |row| row.tag_action.try(:name) }],
                 [:tag_action_value_names, proc { |row| row.model.tag_action_values.map(&:name).join(', ') }],
                 [:lua_script_name, proc { |row| row.lua_script.try(:name) }],
                 [:variables, proc { |row| row.variables_json }],
                 :rewrite_ss_status_name,
                 :created_at, :updated_at

  acts_as_import resource_class: Importing::Numberlist,
                 skip_columns: [:tag_action_value]

  includes :lua_script, :tag_action

  permit_params :name, :mode_id, :default_action_id,
                :default_src_rewrite_rule, :default_src_rewrite_result, :defer_src_rewrite,
                :default_dst_rewrite_rule, :default_dst_rewrite_result, :defer_dst_rewrite,
                :rewrite_ss_status_id,
                :tag_action_id, :lua_script_id, :variables_json, tag_action_value: []
  controller do
    def update
      if params['routing_numberlist']['tag_action_value'].nil?
        params['routing_numberlist']['tag_action_value'] = []
      end
      super
    end
  end

  filter :id
  filter :name
  filter :mode_id_eq, label: 'Mode', as: :select, collection: Routing::Numberlist::MODES.invert
  filter :default_action_id_eq, label: 'Default action', as: :select, collection: Routing::Numberlist::DEFAULT_ACTIONS.invert
  filter :lua_script, input_html: { class: 'chosen' }
  filter :external_id, label: 'External ID'
  filter :external_type
  filter :tag_action, input_html: { class: 'chosen' }, collection: proc { Routing::TagAction.pluck(:name, :id) }
  filter :defer_src_rewrite
  filter :defer_dst_rewrite
  filter :rewrite_ss_status_id_eq,
         label: 'Rewrite SS status',
         as: :select,
         collection: Equipment::StirShaken::Attestation::ATTESTATIONS.invert

  index do
    selectable_column
    id_column
    actions
    column :name
    column :mode, &:mode_name
    column :default_action, &:default_action_name
    column :default_src_rewrite_rule
    column :default_src_rewrite_result
    column :defer_src_rewrite
    column :default_dst_rewrite_rule
    column :default_dst_rewrite_result
    column :defer_dst_rewrite
    column :lua_script
    column :variables, &:variables_json
    column :tag_action
    column :display_tag_action_value
    column :rewrite_ss_status, &:rewrite_ss_status_name
    column :created_at
    column :updated_at
    column 'External ID', :external_id, sortable: :external_id
    column :external_type
  end

  show do |_s|
    attributes_table do
      row :id
      row :name
      row :mode, &:mode_name
      row :created_at
      row :updated_at
      row 'External ID', &:external_id
      row :external_type
    end
    panel 'Default actions' do
      attributes_table_for _s do
        row :default_action, &:default_action_name
        row :default_src_rewrite_rule
        row :default_src_rewrite_result
        row :defer_src_rewrite
        row :default_dst_rewrite_rule
        row :default_dst_rewrite_result
        row :defer_dst_rewrite
        row :lua_script
        row :tag_action
        row :display_tag_action_value
        row :rewrite_ss_status, &:rewrite_ss_status_name
        row :variables do |r|
          pre code JSON.pretty_generate(r.variables)
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :mode_id, as: :select, include_blank: false, collection: Routing::Numberlist::MODES.invert
    end
    f.inputs 'default actions' do
      f.input :default_action_id, as: :select, include_blank: false, collection: Routing::Numberlist::DEFAULT_ACTIONS.invert
      f.input :default_src_rewrite_rule
      f.input :default_src_rewrite_result
      f.input :defer_src_rewrite
      f.input :default_dst_rewrite_rule
      f.input :default_dst_rewrite_result
      f.input :defer_dst_rewrite
      f.input :lua_script, input_html: { class: 'chosen' }, include_blank: 'None'
      f.input :tag_action
      f.input :tag_action_value, as: :select,
                                 collection: tag_action_value_options,
                                 multiple: true,
                                 include_hidden: false,
                                 input_html: { class: 'chosen' }
      f.input :rewrite_ss_status_id, as: :select, collection: Equipment::StirShaken::Attestation::ATTESTATIONS.invert
      f.input :variables_json, label: 'Variables', as: :text
    end
    f.actions
  end

  sidebar :links, only: %i[show edit] do
    ul do
      li do
        link_to 'Customer Auths(as SRC numberlist)', customers_auths_path(q: { src_numberlist_id_eq: params[:id] })
      end
      li do
        link_to 'Customer Auths(as DST numberlist)', customers_auths_path(q: { dst_numberlist_id_eq: params[:id] })
      end
      li do
        link_to 'Gateways(as SRC numberlist)', gateways_path(q: { termination_src_numberlist_id_eq: params[:id] })
      end
      li do
        link_to 'Gateways(as DST numberlist)', gateways_path(q: { termination_dst_numberlist_id_eq: params[:id] })
      end
      li do
        link_to 'Numberlist Items', routing_numberlist_items_path(q: { numberlist_id_eq: params[:id] })
      end
    end
  end
end
