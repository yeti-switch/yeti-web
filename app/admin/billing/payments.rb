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
                 :private_notes,
                 :status

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
    column :status, :status_formatted, sortable: :status_id
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
  filter :status_id,
         label: 'Status',
         as: :select,
         collection: proc { Payment::CONST::STATUS_IDS },
         input_html: { class: 'chosen' }
  filter :amount
  filter :private_notes
  filter :notes

  action_item :check_cryptomus, only: :show do
    if resource.pending?
      link_to 'Check Cryptomus', check_cryptomus_payment_path(resource.id), method: :put
    end
  end

  show do |_s|
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :uuid
          row :created_at
          row :account
          row :status, :status_formatted
          row :amount
          row :private_notes
          row :notes
        end
      end

      if payment.pending?
        tab :cryptomus_info do
          pre do
            cryptomus_info = Cryptomus::Client.payment(order_id: resource.id.to_s)
            JSON.pretty_generate(cryptomus_info)
          rescue Cryptomus::Errors::ApiError => e
            "Response status #{e.status}\n#{JSON.pretty_generate(e.response_body)}"
          end
        end
      end
    end
  end

  member_action :check_cryptomus, method: :put do
    begin
      payment = Draper.undecorate(resource)
      CryptomusPayment::CheckStatus.call(payment:)
      flash[:notice] = 'Payment status updated.'
    rescue CryptomusPayment::CheckStatus::Error => e
      flash[:error] = e.message
    rescue Cryptomus::Errors::ApiError => e
      flash[:error] = "Response status #{e.status}"
    end
    redirect_to payment_path(resource.id)
  end
end
