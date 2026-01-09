# frozen_string_literal: true

ActiveAdmin.register Equipment::Dns::Zone do
  menu parent: %w[Equipment DNS], label: 'DNS Zones', priority: 30
  config.batch_actions = false

  acts_as_audit
  acts_as_clone

  acts_as_export :id, :name, :soa_mname, :soa_rname, :serial, :expire, :refresh, :retry, :minimum

  permit_params :name, :expire, :minimum, :refresh, :retry, :serial, :soa_mname, :soa_rname

  filter :id
  filter :name

  index do
    id_column
    actions
    column :name
    column :soa_mname
    column :soa_rname
    column :expire
    column :minimum
    column :refresh
    column :retry
    column :serial
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :soa_mname
      f.input :soa_rname
      f.input :expire
      f.input :minimum
      f.input :refresh
      f.input :retry
      f.input :serial
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :soa_mname
      row :soa_rname
      row :expire
      row :minimum
      row :refresh
      row :retry
      row :serial
    end
    active_admin_comments
  end
end
