# frozen_string_literal: true

ActiveAdmin.register Billing::PackageCounter, as: 'Package Billing Counters' do
  menu parent: 'Billing', label: 'Package Billing Counters', priority: 11

  actions :index, :show

  acts_as_export :id,
                 :account_id,
                 :service_id,
                 :prefix,
                 :exclude,
                 :duration

  # decorate_with TransactionDecorator

  includes :account, :service

  filter :id
  account_filter :account_id_eq
  filter :service_id, label: 'Service ID'
  filter :prefix
  filter :duration
  filter :exclude

  index do
    selectable_column
    id_column
    actions
    column :account
    column :service, :service_link
    column :prefix
    column :exclude
    column :duration
  end

  show do
    attributes_table do
      row :id
      row :account
      row :service, &:service_link
      row :prefix
      row :exclude
      row :duration
    end
  end
end
