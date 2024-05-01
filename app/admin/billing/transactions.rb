# frozen_string_literal: true

ActiveAdmin.register Billing::Transaction, as: 'Transactions' do
  menu parent: 'Billing', label: 'Transactions', priority: 21

  actions :index, :show

  scope :today
  scope :yesterday

  permit_params :id, :amount, :account_id, :service_id, :description

  acts_as_export :id,
                 :created_at,
                 :account_id,
                 :service_id,
                 :amount,
                 :description

  includes :account, :service

  filter :id
  filter :created_at
  account_filter :account_id_eq
  filter :service
  filter :amount
  filter :description

  index do
    selectable_column
    id_column
    actions
    column :created_at
    column :account
    column :service do |c|
      auto_link c.service || c.service_id
    end
    column :amount
    column :description
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :account
      row :service do |c|
        auto_link c.service || c.service_id
      end
      row :amount
      row :description
    end
  end
end
