ActiveAdmin.register Routing::NumberlistItem do
  menu parent: "Routing", priority: 125, label: 'Numberlist items'

  navigation_menu :default
  config.batch_actions = true

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  includes :numberlist, :action

  permit_params :numberlist_id, :key, :action_id,
                :src_rewrite_rule, :src_rewrite_result,
                :dst_rewrite_rule, :dst_rewrite_result

  filter :id
  filter :numberlist, input_html: {class: 'chosen'}
  filter :key

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
      row :createa_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs do
      f.input :numberlist, input_html: {class: 'chosen'}, hint: I18n.t('hints.routing.numberlist_items.numberlist')
      f.input :key, hint: I18n.t('hints.routing.numberlist_items.key')
      f.input :action, as: :select, include_blank: 'Default action', hint: I18n.t('hints.routing.numberlist_items.action')
      f.input :src_rewrite_rule, hint: I18n.t('hints.routing.numberlist_items.src_rewrite_rule')
      f.input :src_rewrite_result, hint: I18n.t('hints.routing.numberlist_items.src_rewrite_result')
      f.input :dst_rewrite_rule, hint: I18n.t('hints.routing.numberlist_items.dst_rewrite_rule')
      f.input :dst_rewrite_result, hint: I18n.t('hints.routing.numberlist_items.dst_rewrite_result')
    end
    f.actions
  end


end