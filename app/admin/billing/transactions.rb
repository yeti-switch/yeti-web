# frozen_string_literal: true

ActiveAdmin.register Billing::Transaction, as: 'Transactions' do
  menu parent: 'Billing', label: 'Transactions', priority: 21

  actions :index, :show

  acts_as_export :id,
                 :created_at,
                 :account_id,
                 :service_id,
                 :amount,
                 :description

  decorate_with TransactionDecorator

  includes :account, :service

  with_default_params do
    params[:q] = { created_at_gteq_datetime_picker: 0.days.ago.beginning_of_day }
    'Only records from beginning of the day showed by default'
  end

  filter :id
  filter :created_at, as: :date_time_range
  account_filter :account_id_eq
  filter :service_id, label: 'Service ID'
  filter :service, input_html: { class: 'chosen' }
  filter :amount
  filter :description
  filter :uuid_equals, label: 'UUID'

  scope :today
  scope :yesterday

  index do
    selectable_column
    id_column
    actions
    column :created_at
    column :account
    column :service, :service_link
    column :amount
    column :description
    column :uuid
  end

  show do
    attributes_table do
      row :id
      row :uuid
      row :created_at
      row :account
      row :service, &:service_link
      row :amount
      row :description
    end
  end
end
