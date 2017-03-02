ActiveAdmin.register Lnp::RoutingPlanLnpRule do

  menu parent: 'Routing', priority: 54, label: 'Routing plan LNP rules'

  #acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  acts_as_export :id, :name

  permit_params :routing_plan_id, :database_id, :dst_prefix,
                :req_dst_rewrite_rule, :req_dst_rewrite_result,
                :lrn_rewrite_rule, :lrn_rewrite_result

  includes :routing_plan, :database

  index do
    selectable_column
    id_column
    actions
    column :routing_plan
    column :dst_prefix
    column :req_dst_rewrite_rule
    column :req_dst_rewrite_result
    column :database
    column :lrn_rewrite_rule
    column :lrn_rewrite_result
    column :created_at
  end

  filter :id
  filter :name

  show do |s|
    attributes_table do
      row :id
      row :routing_plan
      row :dst_prefix
      row :req_dst_rewrite_rule
      row :req_dst_rewrite_result
      row :database
      row :lrn_rewrite_rule
      row :lrn_rewrite_result
      row :created_at
    end
  end

  form do |f|
    f.inputs do
      f.input :routing_plan
      f.input :dst_prefix
      f.input :req_dst_rewrite_rule
      f.input :req_dst_rewrite_result
      f.input :database
      f.input :lrn_rewrite_rule
      f.input :lrn_rewrite_result
    end
    actions
  end
end
