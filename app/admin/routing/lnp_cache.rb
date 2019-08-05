# frozen_string_literal: true

ActiveAdmin.register Lnp::Cache do
  menu parent: 'Routing', priority: 55, label: 'LNP Cache'
  actions :index, :show, :destroy

  acts_as_safe_destroy
  acts_as_async_destroy('Lnp::Cache')
  acts_as_delayed_job_lock

  acts_as_export :id, :dst, :lrn, :tag, :created_at, :expires_at

  includes :database, :routing_tag

  index do
    selectable_column
    id_column
    actions
    column :dst
    column :lrn
    column :routing_tag
    column :data
    column :database
    column :created_at
    column :expires_at
  end

  filter :id
  filter :dst
  filter :lrn
  filter :routing_tag
  filter :data
  filter :database

  show do |_s|
    attributes_table do
      row :id
      row :dst
      row :lrn
      row :routing_tag
      row :data
      row :database
      row :created_at
      row :expires_at
    end
  end
end
