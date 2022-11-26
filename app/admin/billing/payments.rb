# frozen_string_literal: true

ActiveAdmin.register Payment do
  menu parent: 'Billing', priority: 20

  config.batch_actions = false
  actions :index, :create, :new, :show

  permit_params :account_id, :amount, :notes, :private_notes
  scope :all, default: true
  scope :today
  scope :yesterday

  acts_as_export :id,
                 :uuid,
                 :created_at,
                 [:account_name, proc { |row| row.account.try(:name) }],
                 :amount,
                 :notes,
                 :private_notes

  controller do
    def scoped_collection
      Payment.includes(:account)
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs form_title do
      f.account_input :account_id
      f.input :amount
      f.input :private_notes
      f.input :notes
    end
    f.actions
  end

  index footer_data: ->(collection) { collection.select('round(sum(amount),4) as total_amount').take } do
    id_column
    column :created_at
    column :account, footer: lambda {
                               strong do
                                 'Total:'
                               end
                             }
    column :amount, footer: lambda {
                              strong do
                                @footer_data[:total_amount]
                              end
                            }
    column :private_notes
    column :notes
    column :uuid
  end

  filter :id
  filter :uuid_equals, label: 'UUID'
  filter :created_at, as: :date_time_range
  account_filter :account_id_eq
  filter :amount
  filter :private_notes
  filter :notes

  show do |_s|
    attributes_table do
      row :id
      row :uuid
      row :created_at
      row :account
      row :amount
      row :private_notes
      row :notes
    end
  end
end
