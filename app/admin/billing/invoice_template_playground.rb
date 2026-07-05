# frozen_string_literal: true

# Interactive tool reached from an invoice template's show page ("Playground"
# action): the editor is pre-filled with that template, and the right pane shows
# it rendered against a chosen invoice's real data via yeti-pdf. Nothing is
# saved — the edited template is used only for the on-demand render.
ActiveAdmin.register_page 'Template Playground' do
  menu false

  # POST { invoice_id, template } -> streams the freshly rendered PDF. Nothing is
  # persisted; the edited template is used for this render only.
  page_action :preview, method: :post do
    invoice = Billing::Invoice.find(params[:invoice_id])
    return render(plain: 'Not authorized to read this invoice', status: 403) unless authorized?(:read, invoice)

    data = BillingInvoice::InvoiceData.call(invoice: invoice)
    pdf = YetiPdf::Client.render_pdf(template: params[:template].to_s, data: data)
    send_data pdf, type: 'application/pdf', disposition: 'inline'
  rescue ActiveRecord::RecordNotFound
    render plain: 'Invoice not found', status: 404
  rescue YetiPdf::Client::Error => e
    render plain: e.message, status: :unprocessable_entity
  end

  # GET ?template_id= -> the saved html_template, for the "Rollback" button.
  page_action :template, method: :get do
    template = Billing::InvoiceTemplate.find(params[:template_id])
    render json: { html_template: template.html_template.to_s }
  rescue ActiveRecord::RecordNotFound
    render json: { html_template: '' }, status: 404
  end

  # PATCH -> persist the edited html_template back to the template.
  page_action :save, method: :patch do
    template = Billing::InvoiceTemplate.find(params[:template_id])
    template.update!(html_template: params[:html_template].to_s)
    render json: { ok: true }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Template not found' }, status: 404
  rescue ActiveRecord::RecordInvalid => e
    render json: { error: e.record.errors.full_messages.to_sentence }, status: :unprocessable_entity
  end

  content do
    template = Billing::InvoiceTemplate.find_by(id: params[:template_id])
    invoices = Billing::Invoice.includes(:account).order(created_at: :desc).limit(200)

    # Page-scoped CodeMirror bundle — loaded only here, not on every admin page.
    text_node stylesheet_link_tag('playground')

    div class: 'template-playground',
        'data-preview-url': template_playground_preview_path,
        'data-template-url': template_playground_template_path,
        'data-save-url': template_playground_save_path,
        'data-template-id': template&.id do
      div class: 'tp-toolbar', style: 'display:flex; gap:8px; align-items:center; margin-bottom:8px;' do
        a 'Close', href: (template ? invoice_template_path(template) : invoice_templates_path), class: 'button'
        a 'Rollback', href: '#', id: 'tp-rollback', class: 'button'
        a 'Save', href: '#', id: 'tp-save', class: 'button'
        span id: 'tp-save-status', style: 'color:#3a3;'
        label 'Invoice:', for: 'tp-invoice', style: 'margin-left:auto;'
        select id: 'tp-invoice', class: 'tom-select', style: 'min-width:340px;' do
          invoices.each do |inv|
            option "##{inv.id} — #{inv.reference} — #{inv.account&.name}", value: inv.id
          end
        end
      end

      div class: 'tp-body' do
        div class: 'tp-editor-pane' do
          textarea template&.html_template.to_s, id: 'tp-template', class: 'tp-editor', spellcheck: 'false'
        end
        div class: 'tp-preview' do
          div id: 'tp-error', class: 'tp-error'
          iframe '', id: 'tp-pdf', class: 'tp-frame'
          div class: 'tp-spinner'
        end
      end
    end

    text_node javascript_include_tag('playground')
  end
end
