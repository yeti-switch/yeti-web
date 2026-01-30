# frozen_string_literal: true

ActiveAdmin.register Lnp::RoutingPlanLnpRule do
  menu parent: 'Routing', priority: 54, label: 'Routing plan LNP rules'

  # acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_async_destroy('Lnp::RoutingPlanLnpRule')
  acts_as_async_update BatchUpdateForm::RoutingPlanLnpRule

  acts_as_delayed_job_lock

  acts_as_export :id, :name

  permit_params :routing_plan_id, :database_id, :dst_prefix,
                :req_dst_rewrite_rule, :req_dst_rewrite_result,
                :lrn_rewrite_rule, :lrn_rewrite_result,
                :drop_call_on_error, :rewrite_call_destination

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
    column :drop_call_on_error
    column :rewrite_call_destination
    column :created_at
  end

  filter :id
  filter :dst_prefix
  filter :routing_plan, input_html: { class: 'tom-select' }, collection: proc { Routing::RoutingPlan.pluck(:name, :id) }
  filter :database, input_html: { class: 'tom-select' }, collection: proc { Lnp::Database.pluck(:name, :id) }
  filter :created_at, as: :date_time_range

  show do |_s|
    attributes_table do
      row :id
      row :routing_plan
      row :dst_prefix
      row :req_dst_rewrite_rule
      row :req_dst_rewrite_result
      row :database
      row :lrn_rewrite_rule
      row :lrn_rewrite_result
      row :drop_call_on_error
      row :rewrite_call_destination
      row :created_at
    end
  end

  form do |f|
    f.inputs do
      f.input :routing_plan, input_html: { class: 'tom-select' }
      f.input :dst_prefix
      f.input :req_dst_rewrite_rule
      f.input :req_dst_rewrite_result
      f.input :database, input_html: { class: 'tom-select' }
      f.input :lrn_rewrite_rule
      f.input :lrn_rewrite_result
      f.input :drop_call_on_error
      f.input :rewrite_call_destination
    end
    actions
  end
end
