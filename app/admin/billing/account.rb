ActiveAdmin.register Account do
  menu parent: "Billing", priority: 10

  acts_as_safe_destroy
  acts_as_audit
  acts_as_clone


  decorate_with AccountDecorator

  acts_as_export :id,
                 [:contractor_name, proc { |row| row.contractor.try(:name) }],
                 :name,
                 :balance,
                 :min_balance,
                 :max_balance,
                 :balance_low_threshold,
                 :balance_high_threshold,
                 :origination_capacity,
                 :termination_capacity,
                 :customer_invoice_period,
                 :vendor_invoice_period

  acts_as_import resource_class: Importing::Account

  scope :all
  scope :vendors_accounts
  scope :customers_accounts
  scope :insufficient_balance

  permit_params :uuid, :contractor_id, :balance,
                :min_balance, :max_balance,
                :balance_low_threshold, :balance_high_threshold,
                :name, :origination_capacity,
                :termination_capacity, :customer_invoice_period_id, :vendor_invoice_period_id,
                :autogenerate_vendor_invoices, :autogenerate_customer_invoices,
                :vendor_invoice_template_id, :customer_invoice_template_id, :timezone_id,
                send_invoices_to: [], send_balance_notifications_to: []



  includes :customer_invoice_period, :vendor_invoice_period, :contractor, :timezone

  config.batch_actions = true
  config.scoped_collection_actions_if = -> { true }

  scoped_collection_action :scoped_collection_update,
                           class: 'scoped_collection_action_button ui',
                           form: -> do
                             {
                               contractor_id: Contractor.all.map { |c| [c.name, c.id] },
                               balance: 'text',
                               min_balance: 'text',
                               max_balance: 'text',
                               balance_low_threshold: 'text',
                               balance_high_threshold: 'text',
                               origination_capacity: 'text',
                               termination_capacity: 'text',
                               vendor_invoice_period_id: Billing::InvoicePeriod.all.map { |ip| [ip.name, ip.id] },
                               customer_invoice_period_id: Billing::InvoicePeriod.all.map { |ip| [ip.name, ip.id] },
                               vendor_invoice_template_id: Billing::InvoiceTemplate.all.map { |it| [it.name, it.id]},
                               customer_invoice_template_id: Billing::InvoiceTemplate.all.map { |it| [it.name, it.id] },
                               timezone: 'datepicker'
                             }
                           end


  index footer_data: ->(collection) { BillingDecorator.new(collection.totals)} do
    selectable_column
    actions
    id_column
    column :contractor do |c|
      auto_link(c.contractor, c.contractor.decorated_display_name)
    end
    column :name, footer: -> do
                  strong do
                    "Total:"
                  end
                end

    column :balance, footer: -> do
                     strong do
                       @footer_data.money_format :total_balance
                     #  number_to_currency(@footer_data[:total_balance], delimiter:" ", separator: ".", precision: 4, unit: "")
                     end
                   end do |c|
      strong do
        c.decorated_balance
      end
    end

    column :min_balance do |c|
      c.decorated_min_balance
    end

    column :max_balance do |c|
      c.decorated_max_balance
    end

    column :balance_low_threshold
    column :balance_high_threshold

    column :origination_capacity
    column :termination_capacity

    column :vendor_invoice_period
    column :customer_invoice_period

    column :vendor_invoice_template
    column :customer_invoice_template
    column :timezone
    column :send_invoices_to do |c|
      c.send_invoices_to_emails
    end
    column :send_balance_notifications_to do |c|
      c.send_balance_notifications_to_emails
    end
    column :uuid
  end

  filter :id
  filter :uuid_equals, label: 'UUID'
  filter :contractor, input_html: {class: 'chosen'}
  filter :name
  filter :balance

  show do |s|
    tabs do
      tab :details do
        attributes_table_for s do
          row :id
          row :uuid
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

          row :balance_low_threshold
          row :balance_high_threshold

          row :name
          row :origination_capacity
          row :termination_capacity
          row :vendor_invoice_template
          row :customer_invoice_template
          row :send_invoices_to do |row|
             row.send_invoices_to_emails
          end
          row :send_balance_notifications_to do |row|
            row.send_balance_notifications_to_emails
          end
          row :vendor_invoice_period do
            if s.vendor_invoice_period
              text_node s.vendor_invoice_period.name
              text_node " - "
              text_node s.next_vendor_invoice_at.to_date if s.next_vendor_invoice_at.present?
            end
          end

          row :customer_invoice_period do
            if s.customer_invoice_period
              text_node s.customer_invoice_period.name
              text_node " - "
              text_node s.next_customer_invoice_at.to_date if s.next_customer_invoice_at.present?
            end
          end
          row :timezone

        end

        panel "Last Payments" do
          table_for s.payments.last(10).reverse do
            column :id
            column :created_at
            column :amount
            column :notes
          end
        end

      end
      tab "Comments" do
        active_admin_comments
      end

      tab :active_calls_charts do
        panel "Active Calls 24 h" do
          render partial: 'charts/account_active_calls'
        end
        panel "Customer Calls 1 month" do
          render partial: 'charts/customer_account_agg'
        end
        panel "Vendor Calls 1 month" do
          render partial: 'charts/vendor_account_agg'
        end
      end


      tab "Profitability" do
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
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :uuid, as: :string
      f.input :name
      f.input :contractor, input_html: {class: 'chosen'}
      f.input :min_balance
      f.input :max_balance
      f.input :balance_low_threshold
      f.input :balance_high_threshold
      f.input :origination_capacity
      f.input :termination_capacity
      f.input :vendor_invoice_period
      f.input :customer_invoice_period


      f.input :vendor_invoice_template
      f.input :customer_invoice_template

      f.input :send_invoices_to, as: :select, input_html: {class: 'chosen', multiple: true}, collection: Billing::Contact.collection
      f.input :send_balance_notifications_to, as: :select, input_html: {class: 'chosen', multiple: true}, collection: Billing::Contact.collection
      f.input :timezone, as: :select, input_html: {class: 'chosen'}
    end
    f.actions
  end

  collection_action :with_contractor do
    @accounts = Contractor.find_by(id: params[:contractor_id]).try(:accounts) || Account.none
    render text: view_context.options_from_collection_for_select(@accounts, :id, :display_name)
  end

  sidebar 'Create Payment', only: [:show] do

    active_admin_form_for(Payment.new(account_id: params[:id]),
                          url: payment_account_path(params[:id]),
                          as: :payment,
                          method: :post) do |f|
      f.inputs do
        f.input :account_id, as: :hidden
        f.input :amount, input_html: {style: 'width: 200px'}
        f.input :notes, input_html: {style: 'width: 200px'}
      end
      f.actions
    end
  end

  member_action :payment, method: :post do
    payment_params = params.require(:payment).permit(:account_id, :amount, :notes)
    payment = Payment.new(payment_params)
    if payment.save
      flash[:notice] = 'Payment created!'
    else
      flash[:error] = 'Payment creation failed: ' + payment.errors.full_messages.join(', ')
    end
    redirect_to action: :show
  end

  sidebar :links, only: [:show, :edit] do

    ul do
      li do
        link_to "Payments", payments_path(q: {account_id_eq: params[:id]})

      end
      li do
        link_to "CDR list", cdrs_path(q: {account_id_eq: params[:id]})

      end

    end
  end


end
