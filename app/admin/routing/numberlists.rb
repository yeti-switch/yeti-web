ActiveAdmin.register Routing::Numberlist, as: 'Numberlist' do

  menu parent: "Routing", priority: 110

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  includes :mode, :default_action

  permit_params :name, :mode_id, :default_action_id,
                :default_src_rewrite_rule, :default_src_rewrite_result,
                :default_dst_rewrite_rule, :default_dst_rewrite_result

  config.batch_actions = true
  config.scoped_collection_actions_if = -> { true }

  scoped_collection_action :scoped_collection_update,
                           class: 'scoped_collection_action_button ui',
                           form: -> do
                             {
                               mode_id: Routing::NumberlistMode.all.map{
                                 |mode| [mode.name, mode.id]
                               },
                               default_action_id: Routing::NumberlistAction.all.map{
                                 |default_action| [default_action.name, default_action.id]
                               },
                               default_src_rewrite_rule: 'text',
                               default_src_rewrite_result: 'text',
                               default_dst_rewrite_rule: 'text',
                               default_dst_rewrite_result: 'text'
                             }
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
    column :created_at
    column :updated_at
  end

  show do |s|
    attributes_table do
      row :id
      row :name
      row :mode
      row :default_action
      row :default_src_rewrite_rule
      row :default_src_rewrite_result
      row :default_dst_rewrite_rule
      row :default_dst_rewrite_result
      row :created_at
      row :updated_at
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
    end
    f.actions
  end

  filter :id
  filter :name
  filter :mode
  filter :default_action

end