# frozen_string_literal: true

ActiveAdmin.register Payment do
  menu parent: 'Billing', priority: 20

  config.batch_actions = false
  actions :index, :create, :new, :show
  decorate_with PaymentDecorator

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
                 :status,
                 :type_name,
                 :balance_before_payment,
                 :rolledback_at

  with_default_params do
    params[:q] = { created_at_gteq_datetime_picker: 0.days.ago.beginning_of_day }
    'Only records from beginning of the day showed by default'
  end

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
    column :type, :type_formatted, sortable: :type_id
    column :status, :status_formatted, sortable: :status_id
    column :amount, footer: lambda {
      strong do
        @footer_data[:total_amount]
      end
    }
    column :private_notes
    column :notes
    column :balance_before_payment
    column :rolledback_at
    column :uuid
  end

  filter :id
  filter :uuid_equals, label: 'UUID'
  filter :created_at, as: :date_time_range
  filter :rolledback_at, as: :date_time_range, label: 'RolledBack at'
  account_filter :account_id_eq
  filter :type_id,
         label: 'Type',
         as: :select,
         collection: Payment::CONST::TYPE_IDS.invert.to_a,
         input_html: { class: 'tom-select' }
  filter :status_id,
         label: 'Status',
         as: :select,
         collection: Payment::CONST::STATUS_IDS.invert.to_a,
         input_html: { class: 'tom-select' }
  filter :amount
  filter :private_notes
  filter :balance_before_payment
  filter :notes

  show do |_s|
    tabs do
      tab :details do
        attributes_table do
          row :id
          row :uuid
          row :created_at
          row :account
          row :type, &:type_formatted
          row :status, &:status_formatted
          row :amount
          row :private_notes
          row :balance_before_payment
          row :notes
          row :rolledback_at
        end
      end

      if payment.type_cryptomus?
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

  member_action :rollback, method: :post do
    Payment::Rollback.call(payment: resource)
    flash[:notice] = 'Payment has been rolled back successfully.'
  rescue Payment::Rollback::Error => e
    flash[:error] = e.message
  ensure
    redirect_back fallback_location: root_path
  end

  action_item :rollback, only: :show do
    if authorized?(:rollback, resource)
      hint = "Balance will be restored, status changed, rolledback_at recorded. This action can't be reverted."
      link_to('Rollback', rollback_payment_path(resource.id), method: :post, title: hint)
    end
  end
end
