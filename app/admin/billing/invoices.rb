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
  scope :approved
  scope :pending

  # TODO: Fix, causes error on RSpec
  # acts_as_export

  controller do
    def build_new_resource
      ManualInvoiceForm.new(*resource_params)
    end

    def scoped_collection
      super.preload(:contractor, :account)
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
    if resource.invoice_document.present?
      dropdown_menu 'Files' do
        item('Document (ODT format)', export_file_odt_invoice_path(resource.id), method: :get)
        item('Document (PDF format)', export_file_pdf_invoice_path(resource.id), method: :get)
      end
    end
  end

  action_item :approve, only: :show do
    link_to('Approve', approve_invoice_path(resource.id), method: :post) if resource.approvable?
  end

  index footer_data: ->(collection) { BillingDecorator.new(collection.totals) } do
    selectable_column
    id_column
    actions
    column :reference
    column :contractor, footer: lambda {
      strong do
        'Total:'
      end
    }
    column :account
    column :state
    column :type
    column :start_date
    column :end_date
    column :originated_amount, footer: lambda {
      strong do
        @footer_data.money_format :total_originated_amount
      end
    } do |c|
      strong do
        c.decorated_originated_amount
      end
    end
    column :terminated_amount, footer: lambda {
      strong do
        @footer_data.money_format :total_terminated_amount
      end
    } do |c|
      strong do
        c.decorated_terminated_amount
      end
    end

    column :originated_calls_count, footer: lambda {
      strong do
        @footer_data.total_originated_calls_count.to_i
      end
    }
    column :terminated_calls_count, footer: lambda {
      strong do
        @footer_data.total_terminated_calls_count.to_i
      end
    }
    column :originated_calls_duration, footer: lambda {
      strong do
        @footer_data.time_format_min :total_originated_calls_duration
      end
    }, &:decorated_originated_calls_duration
    column :terminated_calls_duration, footer: lambda {
      strong do
        @footer_data.time_format_min :total_terminated_calls_duration
      end
    }, &:decorated_terminated_calls_duration

    column :originated_billing_duration, footer: lambda {
      strong do
        @footer_data.time_format_min :total_originated_billing_duration
      end
    }, &:decorated_originated_billing_duration
    column :originated_terminated_duration, footer: lambda {
      strong do
        @footer_data.time_format_min :total_terminated_billing_duration
      end
    }, &:decorated_terminated_billing_duration

    column :created_at
    column 'UUID', :uuid
  end

  filter :id
  filter :uuid_equals, label: 'UUID'
  filter :reference
  contractor_filter :contractor_id_eq
  account_filter :account_id_eq
  filter :state
  filter :type
  filter :start_date, as: :date_time_range
  filter :end_date, as: :date_time_range
  filter :originated_amount
  filter :originated_billing_duration
  filter :originated_calls_count
  filter :originated_calls_duration
  filter :terminated_amount
  filter :terminated_billing_duration
  filter :terminated_calls_count
  filter :terminated_calls_duration

  show do |s|
    tabs do
      tab 'Invoice' do
        panel 'Details' do
          attributes_table_for s do
            row :id
            row :uuid
            row :reference
            row(:contractor) { s.contractor || s.contractor_id }
            row :account
            row :state
            row :type
            row :start_date
            row :end_date
            row :created_at
          end
        end
        panel 'Traffic summary' do
          attributes_table_for s do
            row :originated_amount do
              strong do
                s.decorated_originated_amount
              end
            end
            row :originated_calls_count
            row :terminated_amount do
              strong do
                s.decorated_terminated_amount
              end
            end
            row :terminated_calls_count
          end
        end
      end
      tab 'Originated traffic' do
        panel 'Summary' do
          attributes_table_for s do
            row :originated_amount do
              strong do
                s.decorated_originated_amount
              end
            end
            row :originated_calls_count
            row :originated_successful_calls_count
            row :originated_calls_duration do
              s.decorated_originated_calls_duration
            end
            row :originated_billing_duration, title: 'Calls duration rounded according to destination billing intervals' do
              s.decorated_originated_billing_duration
            end
            row :first_originated_call_at
            row :last_originated_call_at
          end
        end
        panel 'By destination(destination prefix)' do
          table_for resource.originated_destinations do
            column :dst_prefix
            column :country
            column :network
            column :rate
            column 'Calls count/successful' do |s|
              "#{s.calls_count}/#{s.successful_calls_count}"
            end
            column 'Duration real/billed' do |s|
              "#{s.decorated_calls_duration} / #{s.decorated_billing_duration}"
            end
            column :amount do |r|
              strong do
                r.decorated_amount
              end
            end
            column :first_call_at
            column :last_call_at
          end
        end
        panel 'By destination number country/network' do
          table_for resource.originated_networks do
            column :country
            column :network
            column :rate
            column 'Calls count/successful' do |s|
              "#{s.calls_count}/#{s.successful_calls_count}"
            end

            column 'Duration real/billed' do |s|
              "#{s.decorated_calls_duration} / #{s.decorated_billing_duration}"
            end

            column :amount do |r|
              strong do
                r.decorated_amount
              end
            end
            column :first_call_at
            column :last_call_at
          end
        end
      end

      tab 'Terminated traffic' do
        panel 'Summary' do
          attributes_table_for s do
            row :terminated_amount do
              strong do
                s.decorated_terminated_amount
              end
            end
            row :terminated_calls_count
            row :terminated_successful_calls_count
            row :terminated_calls_duration do
              s.decorated_terminated_calls_duration
            end
            row :terminated_billing_duration do
              s.decorated_terminated_billing_duration
            end
            row :first_terminated_call_at
            row :last_terminated_call_at
          end
        end
        panel 'By destination(dialpeer prefix)' do
          table_for resource.terminated_destinations do
            column :dst_prefix
            column :country
            column :network
            column :rate
            column 'Calls count/successful' do |s|
              "#{s.calls_count}/#{s.successful_calls_count}"
            end
            column :calls_duration, &:decorated_calls_duration
            column :billing_duration, &:decorated_billing_duration
            column :amount do |r|
              strong do
                r.decorated_amount
              end
            end
            column :first_call_at
            column :last_call_at
          end
        end
        panel 'By destination number country/network' do
          table_for resource.terminated_networks do
            column :country
            column :network
            column :rate
            column 'Calls count/successful' do |s|
              "#{s.calls_count}/#{s.successful_calls_count}"
            end
            column :calls_duration, &:decorated_calls_duration
            column :billing_duration, &:decorated_billing_duration
            column :amount do |r|
              strong do
                r.decorated_amount
              end
            end
            column :first_call_at
            column :last_call_at
          end
        end
      end
    end
  end

  permit_params :contractor_id,
                :account_id,
                :start_date,
                :end_date

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.contractor_input :contractor_id
      f.account_input :account_id,
                      fill_params: { contractor_id_eq: f.object.contractor_id },
                      fill_required: :contractor_id_eq,
                      input_html: {
                        'data-path-params': { 'q[contractor_id_eq]': '.contractor_id-input' }.to_json,
                        'data-required-param': 'q[contractor_id_eq]'
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
