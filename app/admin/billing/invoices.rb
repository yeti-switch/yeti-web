# frozen_string_literal: true

ActiveAdmin.register Billing::Invoice, as: 'Invoice' do
  menu parent: 'Billing', label: 'Invoices', priority: 30

  actions :index, :show, :destroy, :create, :new

  acts_as_audit
  acts_as_safe_destroy
  acts_as_async_destroy('Billing::Invoice')

  acts_as_delayed_job_lock

  decorate_with InvoiceDecorator

  scope :all
  scope :for_customer
  scope :for_vendor
  scope :approved
  scope :pending

  # TODO: Fix, causes error on RSpec
  # acts_as_export

  includes :contractor, :account, :state, :type

  controller do
    def build_new_resource
      ManualInvoiceForm.new(*resource_params)
    end
  end

  batch_action :approve, confirm: 'Are you sure?', if: proc { authorized?(:approve) } do |selection|
    active_admin_config.resource_class.find(selection).each(&:approve)
    redirect_to collection_path, notice: "#{active_admin_config.resource_label.pluralize} are approved!"
  end

  member_action :approve, method: :post do
    if resource.approvable?
      resource.approve
      flash[:notice] = 'Invoice approved'
      redirect_back fallback_location: root_path
    else
      flash[:notice] = 'Invoice can' 't be approved'
      redirect_back fallback_location: root_path
    end
  end

  member_action :regenerate_document, method: :post do
    if resource.regenerate_document_allowed?
      resource.regenerate_document
      flash[:notice] = 'Documents regenerated'
      redirect_back fallback_location: root_path
    else
      flash[:notice] = 'Documents can''t be regenerated'
      redirect_back fallback_location: root_path
    end
  end

  member_action :export_file_odt, method: :get do
    doc = resource.invoice_document
    if doc.present? && doc.data.present?
      send_data doc.data, type: 'application/vnd.oasis.opendocument.text', filename: "#{doc.filename}.odt"
    else
      flash[:notice] = 'File not found'
      redirect_back fallback_location: root_path
    end
  end

  member_action :export_file_csv, method: :get do
    doc = resource.invoice_document
    if doc.present? && doc.csv_data.present?
      send_data doc.csv_data, type: 'text/csv', filename: "#{doc.filename}.csv"
    else
      flash[:notice] = 'File not found'
      redirect_back fallback_location: root_path
    end
  end

  member_action :export_file_xls, method: :get do
    doc = resource.invoice_document
    if doc.present? && doc.xls_data.present?
      send_data doc.xls_data, type: 'text/csv', filename: "#{doc.filename}.xls"
    else
      flash[:notice] = 'File not found'
      redirect_back fallback_location: root_path
    end
  end

  member_action :export_file_pdf, method: :get do
    doc = resource.invoice_document
    if doc.present? && doc.pdf_data.present?
      send_data doc.pdf_data, type: 'application/pdf', filename: "#{doc.filename}.pdf"
    else
      flash[:notice] = 'File not found'
      redirect_back fallback_location: root_path
    end
  end

  action_item :regenerate_documents, only: :show do
    link_to('Regenerate documents', regenerate_document_invoice_path(resource.id), method: :post) if resource.regenerate_document_allowed?
  end

  action_item :documents, only: :show do
    dropdown_menu 'Files' do
      item('Document(ODT format)', export_file_odt_invoice_path(resource.id), method: :get) if resource.invoice_document.present?
      item('Document(PDF format)', export_file_pdf_invoice_path(resource.id), method: :get) if resource.invoice_document.present?
      item('Details(CSV format)', export_file_csv_invoice_path(resource.id), method: :get) if resource.invoice_document.present?
      item('Details(XLS format)', export_file_xls_invoice_path(resource.id), method: :get) if resource.invoice_document.present?
    end
  end

  action_item :approve, only: :show do
    link_to('Approve', approve_invoice_path(resource.id), method: :post) if resource.approvable?
  end

  index footer_data: ->(collection) { BillingDecorator.new(collection.totals) } do
    selectable_column
    id_column
    actions
    column :contractor, footer: lambda {
      strong do
        'Total:'
      end
    }
    column :account
    column :state
    column :start_date
    column :end_date
    column :amount, footer: lambda {
      strong do
        @footer_data.money_format :total_amount
      end
    } do |c|
      strong do
        c.decorated_amount
      end
    end
    column :type
    column :direction, sorting: 'vendor_invoice', &:direction

    column :calls_count, footer: lambda {
      strong do
        @footer_data.total_calls_count.to_i
      end
    }
    column :calls_duration, footer: lambda {
      strong do
        @footer_data.time_format_min :total_calls_duration
      end
    }, &:decorated_calls_duration

    column :billing_duration, footer: lambda {
      strong do
        @footer_data.time_format_min :total_billing_duration
      end
    }, &:decorated_billing_duration

    column :created_at
    column :first_call_at
    column :first_successful_call_at
    column :last_call_at
    column :last_successful_call_at
  end

  filter :id
  filter :contractor,
         input_html: { class: 'chosen-ajax', 'data-path': '/contractors/search' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:contractor_id_eq]
           resource_id ? Contractor.where(id: resource_id) : []
         }

  filter :account,
         input_html: { class: 'chosen-ajax', 'data-path': '/accounts/search' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:account_id_eq]
           resource_id ? Account.where(id: resource_id) : []
         }

  filter :state
  filter :start_date, as: :date_time_range
  filter :end_date, as: :date_time_range
  filter :vendor_invoice, label: 'Direction', as: :select, collection: [['Vendor', true], ['Customer', false]]
  filter :type
  filter :amount
  filter :billing_duration
  filter :calls_count
  filter :calls_duration

  show do |s|
    tabs do
      tab 'Invoice' do
        attributes_table_for s do
          row :id
          row :contractor_id
          row :account
          row :state
          row :start_date
          row :end_date
          row :amount do
            strong do
              s.decorated_amount
            end
          end
          row :calls_count
          row :successful_calls_count
          row :calls_duration do
            s.decorated_calls_duration
          end
          row :billing_duration do
            s.decorated_billing_duration
          end
          row :type
          row :direction do
            s.direction
          end
          row :created_at
          row :first_call_at
          row :last_call_at
          row :first_successful_call_at
          row :last_successful_call_at
        end
      end
      tab 'Destination prefixes' do
        panel '' do
          table_for resource.destinations do
            column :dst_prefix
            column :country
            column :network
            column :rate
            column :calls_count
            column :successful_calls_count
            column :calls_duration, &:decorated_calls_duration
            column :billing_duration, &:decorated_billing_duration
            column :amount do |r|
              strong do
                r.decorated_amount
              end
            end
            column :first_call_at
            column :first_successful_call_at
            column :last_call_at
            column :last_successful_call_at
          end
        end
      end

      tab 'Destination networks' do
        panel '' do
          table_for resource.networks do
            column :country
            column :network
            column :rate
            column :calls_count
            column :successful_calls_count
            column :calls_duration, &:decorated_calls_duration
            column :billing_duration, &:decorated_billing_duration
            column :amount do |r|
              strong do
                r.decorated_amount
              end
            end
            column :first_call_at
            column :first_successful_call_at
            column :last_call_at
            column :last_successful_call_at
          end
        end
      end
    end
  end

  permit_params :is_vendor,
                :contractor_id,
                :account_id,
                :start_date,
                :end_date

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :is_vendor,
              as: :select,
              label: 'Vendor invoice',
              collection: [['Yes', true], ['No', false]],
              include_blank: false,
              input_html: { class: 'chosen' }

      f.input :contractor_id,
              as: :select,
              collection: Contractor.all,
              input_html: {
                class: 'chosen',
                onchange: remote_chosen_request(
                      :get,
                      get_accounts_contractors_path,
                      { contractor_id: '$(this).val()' },
                      :billing_invoice_account_id
                    )
              }

      f.input :account_id,
              as: :select,
              collection: [],
              input_html: { class: 'chosen' }

      f.input :start_date,
              as: :date_time_picker,
              datepicker_options: { defaultTime: '00:00' },
              hint: 'Customer timezone will be used',
              wrapper_html: { class: 'datetime_preset_pair', data: { show_time: 'true' } }

      f.input :end_date,
              as: :date_time_picker,
              datepicker_options: { defaultTime: '00:00' },
              hint: 'Customer timezone will be used'
    end
    f.actions { f.submit('Create Invoice') }
  end

  sidebar :links, only: %i[show edit], if: proc { !assigns[:invoice].first_call_at.nil? && !assigns[:invoice].last_call_at.nil? } do
    ul do
      li do
        if resource.vendor_invoice?
          link_to 'CDR list', cdrs_path(q: { vendor_invoice_id_equals: params[:id], time_start_gteq: resource.first_call_at - 1, time_start_lteq: resource.last_call_at + 1 }), target: '_blank'
        else
          link_to 'CDR list', cdrs_path(q: { customer_invoice_id_equals: params[:id], time_start_gteq: resource.first_call_at - 1, time_start_lteq: resource.last_call_at + 1 }), target: '_blank'
        end
      end
    end
  end
end
