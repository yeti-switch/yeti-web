# frozen_string_literal: true

ActiveAdmin.register Billing::InvoiceEmailTemplate, as: 'InvoiceEmailTemplate' do
  menu parent: %w[Billing Settings], label: 'Invoice email template', priority: 92
  config.batch_actions = false
  config.filters = false

  # One system-wide row, so there is nothing to list, create or delete — the
  # menu entry behaves like a settings page.
  actions :index, :show, :edit, :update

  permit_params :subject, :html_body, :text_body

  controller do
    def index
      redirect_to invoice_email_template_path(1)
    end
  end

  # Both parts in one view: an email that looks right in HTML and unreadable in
  # plain text is only half checked.
  member_action :preview, method: :get do
    assigns = InvoiceMail.sample_assigns
    text_part = ERB::Util.html_escape(resource.render_text_body(assigns))
    html_part = SandboxedEmailFrame.render(resource.render_html_body(assigns), style: 'width:100%;height:70vh')

    render html: <<~HTML.html_safe, layout: false
      <div style="font-family:Arial,Helvetica,sans-serif;padding:16px;">
        <h3>Plain text part</h3>
        <pre style="border:1px solid #ddd;background:#fff;padding:12px;white-space:pre-wrap;">#{text_part}</pre>
        <h3>HTML part</h3>
        #{html_part}
      </div>
    HTML
  rescue StandardError => e
    flash[:warning] = "Template cannot be rendered: #{e.message}"
    redirect_to action: :show
  end

  action_item :preview, only: [:show] do
    link_to 'Preview', preview_invoice_email_template_path(resource), target: '_blank', rel: 'noopener'
  end

  show do |t|
    attributes_table do
      row :subject
    end

    panel 'Plain text body' do
      pre(style: 'white-space: pre-wrap; word-break: break-word;') { t.text_body }
    end

    panel 'HTML body' do
      # Rendered as <pre><code class="language-django">; highlight.js (loaded in
      # active_admin.js) highlights it on load. The django/jinja grammar
      # sub-highlights the HTML and the {{ }} / {% %} tags — liquid shares that
      # syntax, and django is the grammar already in the bundle. Arbre
      # HTML-escapes the String, so it is shown as source, not rendered.
      pre(style: 'white-space: pre-wrap; word-break: break-word;') do
        code(class: 'language-django') { t.html_body }
      end
    end

    panel 'Available variables' do
      para 'Templates are rendered with liquid. Only the variables below are available; ' \
           'nothing else about the invoice or account can be referenced.'
      table_for InvoiceMail.variable_reference do
        column('Variable') { |r| code "{{ #{r[:name]} }}" }
        column('Example') { |r| r[:example] }
      end
      para 'Money values are exact decimal strings, so a bare {% if amount %} is always true — ' \
           'compare explicitly. Dates are ISO-8601 strings; format them with {{ invoice.end_date | date: "%Y-%m-%d" }}.'
      para 'Email clients are not browsers: in the HTML body use inline styles and table layout only, ' \
           'and keep the plain text body readable on its own — some recipients never see the HTML part.'
    end

    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :subject, hint: 'Liquid. Example: Invoice {{ invoice.reference }}'
      f.input :text_body, as: :text,
                          input_html: { rows: 15, style: 'font-family: monospace;' },
                          hint: 'Plain text alternative part, sent alongside the HTML body.'
      f.input :html_body, as: :text, input_html: { rows: 25, style: 'font-family: monospace;' }
    end
    f.actions
  end
end
