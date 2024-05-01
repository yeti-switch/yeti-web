# frozen_string_literal: true

ActiveAdmin.register Billing::Service, as: 'Services' do
  menu parent: 'Billing', label: 'Services', priority: 30

  scope :all
  scope :for_renew
  scope :one_time_services

  permit_params :id, :name, :account_id, :type_id, :variables, :initial_price, :renew_price, :renew_at

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_export :id,
                 :name,
                 :type_id,
                 :variables

  includes :type, :account

  filter :id
  filter :created_at
  filter :name
  account_filter :account_id_eq
  filter :type
  filter :initial_price
  filter :renew_price
  filter :renew_at

  index do
    selectable_column
    id_column
    actions
    column :name
    column :account
    column :type
    column :variables
    column :initial_price
    column :renew_price
    column :created_at
    column :renew_at
    column :uuid
  end

  show do
    attributes_table do
      row :id
      row :name
      row :account
      row :type
      row :variables
      row :initial_price
      row :renew_price
      row :created_at
      row :renew_at
      row :uuid
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :name

      if f.object.new_record?
        f.account_input :account_id
        f.input :type
      end
      f.input :variables
      if f.object.new_record?
        f.input :initial_price
      end

      f.input :renew_price
      if f.object.new_record?
        f.input :renew_at, as: :date_time_picker
      end
    end
    f.actions
  end
end
