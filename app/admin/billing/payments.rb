# frozen_string_literal: true

ActiveAdmin.register Payment do
  menu parent: 'Billing', priority: 20

  config.batch_actions = false
  actions :index, :create, :new, :show

  permit_params :account_id, :amount, :notes
  scope :all, default: true
  scope :today
  scope :yesterday

  acts_as_export :id,
                 :created_at,
                 [:account_name, proc { |row| row.account.try(:name) }],
                 :amount,
                 :notes

  controller do
    def scoped_collection
      Payment.includes(:account)
    end
  end

  form do |f|
    f.inputs form_title do
      f.input :account, input_html: { class: 'chosen' }, collection: Account.reorder(:name)
      f.input :amount
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
    column :notes
  end

  filter :id
  filter :created_at, as: :date_time_range
  account_filter :account_id_eq
  filter :amount
  filter :notes
end
