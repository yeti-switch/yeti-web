# frozen_string_literal: true

ActiveAdmin.register Billing::PackageCounter, as: 'Package Counters' do
  menu parent: 'Billing', label: 'Package Counters', priority: 11

  actions :index, :show

  acts_as_export :id,
                 [:account_name, proc { |row| row.account.try(:name) }],
                 [:service_name, proc { |row| row.service.try(:name) }],
                 :prefix,
                 :exclude,
                 :duration

  # decorate_with TransactionDecorator

  includes :account, :service

  filter :id
  account_filter :account_id_eq
  filter :service
  filter :prefix
  filter :duration
  filter :exclude

  index do
    selectable_column
    id_column
    actions
    column :account
    column :service
    column :prefix
    column :exclude
    column :duration
  end

  show do
    attributes_table do
      row :id
      row :account
      row :service
      row :prefix
      row :exclude
      row :duration
    end
  end
end
