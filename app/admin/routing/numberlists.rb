ActiveAdmin.register Routing::Numberlist, as: 'Numberlist' do

  menu parent: "Routing", priority: 110

  decorate_with NumberlistDecorator

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_async_destroy('Routing::Numberlist')
  acts_as_async_update('Routing::Numberlist',
                       lambda do
                         {
                           mode_id: Routing::NumberlistMode.pluck(:name, :id),
                           default_action_id: Routing::NumberlistAction.pluck(:name, :id),
                           default_src_rewrite_rule: 'text',
                           default_src_rewrite_result: 'text',
                           default_dst_rewrite_rule: 'text',
                           default_dst_rewrite_result: 'text'
                         }
                       end)

  acts_as_delayed_job_lock

  includes :mode, :default_action

  permit_params :name, :mode_id, :default_action_id,
                :default_src_rewrite_rule, :default_src_rewrite_result,
                :default_dst_rewrite_rule, :default_dst_rewrite_result,
                :tag_action_id, tag_action_value: []
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
    column :created_at
    column :updated_at
    column :tag_action
    column :routing_tags
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
      row :tag_action
      row :routing_tags
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

end
