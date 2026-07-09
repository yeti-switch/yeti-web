# frozen_string_literal: true

ActiveAdmin.register Billing::Invoice, as: 'Invoice' do
  menu parent: 'Billing', label: 'Invoices', priority: 30

  actions :index, :show, :destroy, :create, :new

  acts_as_audit
  acts_as_safe_destroy
  acts_as_async_destroy('Billing::Invoice')

  acts_as_delayed_job_lock

  decorate_with InvoiceDecorator

  scope :all, default: true
  scope :approved
  scope :pending

  # TODO: Fix, causes error on RSpec
  # acts_as_export

  controller do
    def build_new_resource
      ManualInvoiceForm.new(*resource_params)
    end

    def scoped_collection
      # preload invoice_document WITHOUT its (large) pdf_data blob — a boolean is
      # enough to decide whether to show the index download icon
      super.preload(:contractor, :account, :currency, :invoice_document_summary)
    end
  end

  batch_action :approve, confirm: 'Are you sure?', if: proc { authorized?(:approve) } do |selection|
    active_admin_config.resource_class.find(selection).each do |record|
      BillingInvoice::Approve.call(invoice: record)
      flash[:notice] = "#{active_admin_config.resource_label.pluralize} are approved!"
    rescue BillingInvoice::Approve::Error => e
      flash[:error] = "##{record.id}, #{e.message}"
      break
    end

    redirect_to collection_path
  end

  member_action :approve, method: :post do
    BillingInvoice::Approve.call(invoice: resource)
    flash[:notice] = 'Invoice was successful approved'
  rescue BillingInvoice::Approve::Error => e
    flash[:error] = e.message
  ensure
    redirect_back fallback_location: root_path
  end

  # Changing the reference is a dedicated action rather than a generic resource
  # update: it is the only mutable field on a (pending) invoice. Authorization
  # goes through InvoicePolicy#change_reference? (aliased to #update?, pending-only).
  member_action :change_reference, method: :post do
    resource.update!(reference: params[:reference])
    # The reference is printed on the PDF, so regenerate it by default; the modal
    # checkbox lets the admin opt out. Guarded by regenerate_document_allowed?
    # (pending-only) for parity with the standalone regenerate action.
    if ActiveModel::Type::Boolean.new.cast(params[:regenerate_pdf]) && resource.regenerate_document_allowed?
      resource.regenerate_document
    end
    flash[:notice] = 'Invoice reference was updated'
  rescue ActiveRecord::RecordInvalid => e
    flash[:error] = e.message
  ensure
    redirect_to action: :show
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

  member_action :export_file_pdf, method: :get do
    doc = resource.invoice_document
    if doc.present? && doc.pdf_data.present?
      send_data doc.pdf_data, type: 'application/pdf', filename: "#{doc.filename}.pdf"
    else
      flash[:notice] = 'File not found'
      redirect_back fallback_location: root_path
    end
  end

  # Serves the PDF inline (disposition: inline) so it renders in the browser
  # rather than downloading. Used by the lazy-loaded "PDF" tab iframe on the
  # show page, which requests this only when the tab is opened.
  member_action :pdf, method: :get do
    doc = resource.invoice_document
    if doc.present? && doc.pdf_data.present?
      send_data doc.pdf_data, type: 'application/pdf', disposition: 'inline', filename: "#{doc.filename}.pdf"
    else
      head 404
    end
  end

  action_item :regenerate_documents, only: :show do
    link_to('Rebuild PDF', regenerate_document_invoice_path(resource.id), method: :post) if resource.regenerate_document_allowed?
  end

  action_item :documents, only: :show do
    if resource.invoice_document.present?
      link_to('Download PDF', export_file_pdf_invoice_path(resource.id), method: :get)
    end
  end

  action_item :approve, only: :show do
    link_to('Approve', approve_invoice_path(resource.id), method: :post) if resource.approvable?
  end

  # Reference is edited via a modal dialog (modal_link.js) instead of a separate
  # edit form. Only offered for pending invoices the current admin may change.
  # data-values prefills the current reference so clicking OK can't blank it.
  action_item :change_reference, only: :show do
    if authorized?(:change_reference, resource)
      link_to 'Change Reference',
              change_reference_invoice_path(resource),
              class: 'modal-link',
              data: {
                method: :post,
                confirm: 'Change Reference',
                inputs: { reference: :text, regenerate_pdf: :checkbox }.to_json,
                values: { reference: resource.reference, regenerate_pdf: true }.to_json,
                labels: { regenerate_pdf: 'Rebuild PDF' }.to_json
              }
    end
  end

  # Footer helpers: render one line per currency (amounts in different currencies
  # can't be summed, so every money/count/duration total is grouped by currency).
  money_footer = ->(attr) { -> { @footer_data.each { |d| div { strong { d.money_format(attr) } } } } }
  int_footer = ->(attr) { -> { @footer_data.each { |d| div { strong { d.public_send(attr).to_i } } } } }
  dur_footer = ->(attr) { -> { @footer_data.each { |d| div { strong { d.time_format_min(attr) } } } } }

  index footer_data: ->(collection) { collection.totals_per_currency.map { |t| BillingDecorator.new(t) } } do
    selectable_column
    column(:id, sortable: :id) do |inv|
      parts = [link_to(inv.id, resource_path(inv), class: 'resource_id_link')]
      doc = inv.invoice_document_summary
      if doc && ActiveModel::Type::Boolean.new.cast(doc.pdf_present)
        parts << link_to(fa_icon('file-pdf-o'), export_file_pdf_invoice_path(inv), title: 'Download PDF')
      end
      if inv.pdf_error.present?
        parts << content_tag(:span, fa_icon('exclamation-triangle'),
                             title: 'PDF generation failure', style: 'color:#c00; cursor:help;')
      end
      safe_join(parts, ' ')
    end
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
    column :amount_total, footer: lambda {
      @footer_data.each do |d|
        div do
          status_tag(d.currency_name)
          text_node ' '
          strong { d.money_format(:total_amount_total) }
        end
      end
    } do |c|
      status_tag(c.currency&.name)
      text_node ' '
      strong { c.decorated_amount_total }
    end
    column :amount_spent, footer: money_footer.call(:total_amount_spent) do |c|
      strong { c.decorated_amount_spent }
    end
    column :amount_earned, footer: money_footer.call(:total_amount_earned) do |c|
      strong { c.decorated_amount_earned }
    end

    column :originated_amount_spent, footer: money_footer.call(:total_originated_amount_spent) do |c|
      strong { c.decorated_originated_amount_spent }
    end
    column :originated_amount_earned, footer: money_footer.call(:total_originated_amount_earned) do |c|
      strong { c.decorated_originated_amount_earned }
    end

    column :terminated_amount_spent, footer: money_footer.call(:total_terminated_amount_spent) do |c|
      strong { c.decorated_terminated_amount_spent }
    end
    column :terminated_amount_earned, footer: money_footer.call(:total_terminated_amount_earned) do |c|
      strong { c.decorated_terminated_amount_earned }
    end

    column :originated_calls_count, footer: int_footer.call(:total_originated_calls_count)
    column :terminated_calls_count, footer: int_footer.call(:total_terminated_calls_count)
    column :originated_calls_duration, footer: dur_footer.call(:total_originated_calls_duration),
                                       &:decorated_originated_calls_duration
    column :terminated_calls_duration, footer: dur_footer.call(:total_terminated_calls_duration),
                                       &:decorated_terminated_calls_duration

    column :originated_billing_duration, footer: dur_footer.call(:total_originated_billing_duration),
                                         &:decorated_originated_billing_duration
    column :originated_terminated_duration, footer: dur_footer.call(:total_terminated_billing_duration),
                                            &:decorated_terminated_billing_duration

    column :services_amount_spent, footer: money_footer.call(:total_services_amount_spent) do |c|
      strong { c.decorated_services_amount_spent }
    end
    column :services_amount_earned, footer: money_footer.call(:total_services_amount_earned) do |c|
      strong { c.decorated_services_amount_earned }
    end
    column :services_transactions_count, footer: int_footer.call(:total_service_transactions_count)

    column :created_at
    column 'UUID', :uuid
  end

  filter :id
  filter :uuid_equals, label: 'UUID'
  filter :reference
  contractor_filter :contractor_id_eq
  account_filter :account_id_eq
  # currencies live in the primary DB, so filter on the scalar currency_id column
  # (no cross-DB join like a `filter :currency` association would need).
  filter :currency_id,
         as: :select,
         collection: -> { Billing::Currency.order(:name).pluck(:name, :id) },
         input_html: { class: 'tom-select' }
  filter :state
  filter :type
  filter :start_date, as: :date_time_range
  filter :end_date, as: :date_time_range

  filter :amount_total
  filter :amount_spent
  filter :amount_earned

  filter :originated_amount_spent
  filter :originated_amount_earned
  filter :terminated_amount_spent
  filter :terminated_amount_earned

  filter :originated_billing_duration
  filter :originated_calls_count
  filter :originated_calls_duration
  filter :terminated_billing_duration
  filter :terminated_calls_count
  filter :terminated_calls_duration
  filter :services_amount_spent
  filter :services_amount_earned
  filter :services_transactions_count

  show do |s|
    pdf_tab_title = if s.pdf_error.present?
                      safe_join(['PDF ', content_tag(:span, fa_icon('exclamation-triangle'),
                                                     style: 'color:#c00;', title: 'PDF generation failure')])
                    else
                      'PDF'
                    end
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

            row :amount_total do
              strong do
                s.decorated_amount_total
              end
            end
            row :amount_spent do
              strong do
                s.decorated_amount_spent
              end
            end
            row :amount_earned do
              strong do
                s.decorated_amount_earned
              end
            end
          end
        end
        panel 'Traffic summary' do
          attributes_table_for s do
            row :originated_amount_spent do
              strong do
                s.decorated_originated_amount_spent
              end
            end
            row :originated_amount_earned do
              strong do
                s.decorated_originated_amount_earned
              end
            end
            row :originated_calls_count
            row :terminated_amount_spent do
              strong do
                s.decorated_terminated_amount_spent
              end
            end
            row :terminated_amount_earned do
              strong do
                s.decorated_terminated_amount_earned
              end
            end
            row :terminated_calls_count
          end
        end
      end

      tab 'Originated traffic' do
        panel 'Summary' do
          attributes_table_for s do
            row :originated_amount_spent do
              strong do
                s.decorated_originated_amount_spent
              end
            end
            row :originated_amount_earned do
              strong do
                s.decorated_originated_amount_earned
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
            column 'type' do |s|
              s.spent ? status_tag('spent', class: :blue) : status_tag('earned', class: :green)
            end
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
            column 'type' do |s|
              s.spent ? status_tag('spent', class: :blue) : status_tag('earned', class: :green)
            end
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
            row :terminated_amount_spent do
              strong do
                s.decorated_terminated_amount_spent
              end
            end
            row :terminated_amount_earned do
              strong do
                s.decorated_terminated_amount_earned
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
            column 'type' do |s|
              s.spent ? status_tag('spent', class: :blue) : status_tag('earned', class: :green)
            end
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
            column 'type' do |s|
              s.spent ? status_tag('spent', class: :blue) : status_tag('earned', class: :green)
            end
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

      tab 'Services data' do
        panel 'Summary' do
          attributes_table_for s do
            row :services_amount_spent do
              strong do
                s.decorated_services_amount_spent
              end
            end
            row :services_amount_earned do
              strong do
                s.decorated_services_amount_earned
              end
            end
            row :services_transactions_count
          end
        end
        panel 'By service' do
          table_for InvoiceServiceDataDecorator.decorate_collection(resource.service_data.preload(:service)) do
            column :type, :type_badge
            column :service, :service_link
            column :amount do |r|
              strong { r.decorated_amount }
            end
            column :transactions_count
          end
        end
      end

      tab pdf_tab_title, id: 'pdf' do
        if s.pdf_error.present?
          panel 'PDF generation error' do
            pre(style: 'white-space: pre-wrap; word-break: break-word; color: #c00;') { s.pdf_error }
          end
        end
        if s.invoice_document&.pdf_data.present?
          # The iframe carries the PDF url in data-src, not src: ajax_tab.js sets
          # src only when this tab is activated, so the document is fetched on
          # demand instead of on every show-page load.
          iframe '',
                 class: 'invoice-pdf-frame',
                 'data-src': pdf_invoice_path(s),
                 style: 'width: 100%; height: 80vh; border: 0;',
                 title: "Invoice #{s.reference} PDF"
        elsif s.pdf_error.blank?
          para 'PDF document has not been generated yet.'
        end
      end
    end
  end

  # Only manual-invoice creation goes through the resource form; the reference is
  # changed via the dedicated change_reference member action.
  permit_params :contractor_id, :account_id, :start_date, :end_date

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
              hint: 'Account timezone will be used',
              wrapper_html: { class: 'datetime_preset_pair', data: { show_time: 'true' } }

      f.input :end_date,
              as: :date_time_picker,
              datepicker_options: { defaultTime: '00:00' },
              hint: 'Account timezone will be used'
    end
    f.actions { f.submit('Create Invoice') }
  end
end
