# frozen_string_literal: true

ActiveAdmin.register Account do
  menu parent: 'Billing', priority: 10
  search_support!
  acts_as_safe_destroy
  acts_as_audit
  acts_as_clone
  acts_as_async_destroy('Account')
  acts_as_async_update BatchUpdateForm::Account

  acts_as_delayed_job_lock

  decorate_with AccountDecorator

  acts_as_export :id,
                 [:contractor_name, proc { |row| row.contractor.try(:name) }],
                 :name,
                 :balance,
                 :min_balance,
                 :max_balance,
                 :vat,
                 :balance_low_threshold,
                 :balance_high_threshold,
                 :destination_rate_limit,
                 :max_call_duration,
                 :origination_capacity,
                 :termination_capacity,
                 :total_capacity,
                 :customer_invoice_period,
                 :vendor_invoice_period

  acts_as_import resource_class: Importing::Account

  controller do
    def build_new_resource
      AccountForm.new(*resource_params)
    end

    def find_resource
      record = super
      record = AccountForm.new(record) if params[:action].in? %w[edit update]
      record
    end

    # Better not to use includes, because it generates select count(*) from (select distinct ...) queries and such queries very slow
    # see https://github.com/rails/rails/issues/42331
    # https://github.com/yeti-switch/yeti-web/pull/985
    #
    # preload have more controllable behavior, but sorting by associated tables not possible
    def scoped_collection
      super.preload(:customer_invoice_period, :vendor_invoice_period, :contractor, :timezone,
                    :vendor_invoice_template, :customer_invoice_template)
    end
  end

  scope :all
  scope :vendors_accounts
  scope :customers_accounts
  scope :insufficient_balance

  permit_params :uuid, :contractor_id, :balance,
                :min_balance, :max_balance, :vat,
                :balance_low_threshold, :balance_high_threshold,
                :name, :origination_capacity, :termination_capacity, :total_capacity,
                :destination_rate_limit, :max_call_duration,
                :customer_invoice_period_id, :vendor_invoice_period_id,
                :autogenerate_vendor_invoices, :autogenerate_customer_invoices,
                :vendor_invoice_template_id, :customer_invoice_template_id, :timezone_id,
                :customer_invoice_ref_template, :vendor_invoice_ref_template,
                send_invoices_to: [], send_balance_notifications_to: []

  index footer_data: ->(collection) { BillingDecorator.new(collection.totals) } do
    selectable_column
    actions
    id_column
    column :contractor do |c|
      auto_link(c.contractor, c.contractor.decorated_display_name)
    end
    column :name, footer: lambda {
                            strong do
                              'Total:'
                            end
                          }

    column :balance, footer: lambda {
                               strong do
                                 @footer_data.money_format :total_balance
                                 #  number_to_currency(@footer_data[:total_balance], delimiter:" ", separator: ".", precision: 4, unit: "")
                               end
                             } do |c|
      strong do
        c.decorated_balance
      end
    end

    column :min_balance, &:decorated_min_balance

    column :max_balance, &:decorated_max_balance

    column :balance_low_threshold
    column :balance_high_threshold
    column :vat
    column :destination_rate_limit
    column :max_call_duration

    column :origination_capacity
    column :termination_capacity
    column :total_capacity

    column :vendor_invoice_period
    column :customer_invoice_period

    column :vendor_invoice_template
    column :customer_invoice_template
    column :timezone
    column :send_invoices_to, &:send_invoices_to_emails
    column :send_balance_notifications_to, &:send_balance_notifications_to_emails
    column :external_id
    column :uuid
  end

  filter :id
  filter :uuid_equals, label: 'UUID'
  contractor_filter :contractor_id_eq

  filter :name
  filter :balance
  filter :vat
  filter :external_id

  show do |s|
    tabs do
      tab :details do
        attributes_table_for s do
          row :id
          row :uuid
          row :external_id
          row :contractor
          row :balance do
            s.decorated_balance
          end

          row :min_balance do
            s.decorated_min_balance
          end

          row :max_balance do
            s.decorated_max_balance
          end

          row :vat
          row :balance_low_threshold
          row :balance_high_threshold
          row :destination_rate_limit
          row :max_call_duration

          row :name
          row :origination_capacity
          row :termination_capacity
          row :total_capacity

          row :vendor_invoice_template
          row :customer_invoice_template
          row :send_invoices_to, &:send_invoices_to_emails
          row :send_balance_notifications_to, &:send_balance_notifications_to_emails
          row :vendor_invoice_period do
            if s.vendor_invoice_period
              text_node s.vendor_invoice_period.name
              text_node ' - '
              text_node s.next_vendor_invoice_at.to_date if s.next_vendor_invoice_at.present?
            end
          end

          row :customer_invoice_period do
            if s.customer_invoice_period
              text_node s.customer_invoice_period.name
              text_node ' - '
              text_node s.next_customer_invoice_at.to_date if s.next_customer_invoice_at.present?
            end
          end
          row :timezone
          row :customer_invoice_ref_template
          row :vendor_invoice_ref_template
        end

        panel 'Last Payments' do
          table_for s.payments.last(10).reverse do
            column :id
            column :created_at
            column :amount
            column :notes
          end
        end
      end
      tab 'Comments' do
        active_admin_comments
      end

      tab :active_calls_charts do
        panel 'Active Calls 24 h' do
          render partial: 'charts/account_active_calls'
        end
        panel 'Customer Calls 1 month' do
          render partial: 'charts/customer_account_agg'
        end
        panel 'Vendor Calls 1 month' do
          render partial: 'charts/vendor_account_agg'
        end
      end

      tab 'Profitability' do
        panel 'Customer' do
          render partial: 'charts/customer_profit'
        end
        panel 'Vendor' do
          render partial: 'charts/vendor_profit'
        end
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.contractor_input :contractor_id
      f.input :min_balance
      f.input :max_balance
      f.input :vat
      f.input :balance_low_threshold
      f.input :balance_high_threshold

      f.input :destination_rate_limit
      f.input :max_call_duration

      f.input :origination_capacity
      f.input :termination_capacity
      f.input :total_capacity

      f.input :vendor_invoice_period_id, as: :select, input_html: { class: 'chosen' }, collection: Billing::InvoicePeriod.all
      f.input :customer_invoice_period_id, as: :select, input_html: { class: 'chosen' }, collection: Billing::InvoicePeriod.all

      f.input :vendor_invoice_template_id, as: :select, input_html: { class: 'chosen' }, collection: Billing::InvoiceTemplate.all
      f.input :customer_invoice_template_id, as: :select, input_html: { class: 'chosen' }, collection: Billing::InvoiceTemplate.all

      f.input :send_invoices_to, as: :select, input_html: { class: 'chosen', multiple: true }, collection: Billing::Contact.collection
      f.input :send_balance_notifications_to, as: :select, input_html: { class: 'chosen', multiple: true }, collection: Billing::Contact.collection
      f.input :timezone_id, as: :select, input_html: { class: 'chosen' }, collection: System::Timezone.all
      f.input :customer_invoice_ref_template
      f.input :vendor_invoice_ref_template
      f.input :uuid, as: :string
    end
    f.actions
  end

  sidebar 'Create Payment', only: [:show] do
    active_admin_form_for(Payment.new(account_id: params[:id]),
                          url: payment_account_path(params[:id]),
                          as: :payment,
                          method: :post) do |f|
      f.inputs do
        f.input :account_id, as: :hidden
        f.input :amount, input_html: { style: 'width: 200px' }
        f.input :notes, input_html: { style: 'width: 200px' }
      end
      f.actions
    end
  end

  member_action :payment, method: :post do
    authorize!
    payment_params = params.require(:payment).permit(:account_id, :amount, :notes)
    payment = Payment.new(payment_params)
    if payment.save
      flash[:notice] = 'Payment created!'
    else
      flash[:error] = 'Payment creation failed: ' + payment.errors.full_messages.join(', ')
    end
    redirect_to action: :show
  end

  sidebar :links, only: %i[show edit] do
    ul do
      li do
        link_to 'Payments', payments_path(q: { account_id_eq: params[:id] })
      end
      li do
        link_to 'CDR list', cdrs_path(q: { account_id_eq: params[:id] })
      end
    end
  end
end
