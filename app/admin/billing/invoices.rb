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
    column 'UUID', :uuid
    actions
    column :reference
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
  filter :uuid_equals, label: 'UUID'
  filter :reference
  contractor_filter :contractor_id_eq

  account_filter :account_id_eq,
                 input_html: {
                   class: 'contractor_id_eq-filter-child',
                   'data-path-parents': { 'q[contractor_id_eq]': '.contractor_id_eq-filter' }.to_json,
                   'data-path-required-parent': '.contractor_id_eq-filter'
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
          row :uuid
          row :reference
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
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :is_vendor,
              as: :select,
              label: 'Vendor invoice',
              collection: [['Yes', true], ['No', false]],
              include_blank: false,
              input_html: { class: 'chosen' }

      f.contractor_input :contractor_id
      f.account_input :account_id,
                      input_html: {
                        class: 'contractor_id-input-child',
                        'data-path-parents': { 'q[contractor_id_eq]': '.contractor_id-input' }.to_json,
                        'data-path-required-parent': '.contractor_id-input'
                      }

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
end
