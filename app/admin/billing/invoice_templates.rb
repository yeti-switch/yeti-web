# frozen_string_literal: true

ActiveAdmin.register Billing::InvoiceTemplate, as: 'InvoiceTemplate' do
  menu parent: %w[Billing Settings], label: 'Invoice templates', priority: 90
  config.batch_actions = false
  actions :all # :index,:create, :new, :destroy, :delete, :edit, :update
  before_action :left_sidebar!

  permit_params :name, :template_file, :html_template

  acts_as_export :id, :name,
                 [:file_name, proc { |row| row.filename }],
                 :created_at,
                 :sha1

  member_action :download, method: :get do
    if resource.data.present?
      send_data resource.data, type: 'application/vnd.oasis.opendocument.text', filename: resource.filename
    else
      send_data resource.html_template, type: 'text/html', filename: "#{resource.name}.html"
    end
  end

  controller do
    def scoped_collection
      super.select('created_at, sha1, id, name, filename, html_template')
    end

    def find_resource
      scoped_collection.except(:select).find(params[:id])
    end
  end

  index do
    id_column
    actions
    # column :actions, defaults: false do  |row|
    #   link_to 'Delete', resource_path(row), method: :delete, data: {confirm: I18n.t('active_admin.delete_confirmation')}, class: "member_link delete_link"
    # end

    column :name

    column 'Type' do |row|
      row.html_template.present? ? status_tag('HTML', class: 'ok') : status_tag('ODT')
    end
    column 'File' do |row|
      label = row.filename.presence || "#{row.name}.html"
      link_to label, download_invoice_template_path(row), method: :get
    end
    column :created_at
    column :sha1
  end

  filter :id, as: :numeric
  filter :name
  filter :filename

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :html_template, as: :text, input_html: { rows: 24 },
                              hint: 'HTML/pongo2 template. When set (and invoice.pdf_api is configured) the invoice PDF is rendered by the yeti-pdf service. Leave blank to use the legacy ODT template below.'
      f.input :template_file, as: :file, hint: 'Legacy ODT template (used only when no HTML template is set).'
    end
    f.actions
    panel 'HTML template variables (yeti-pdf)' do
      text_node <<~HTML.html_safe
        Reference values with nested names, e.g. <code>{{ account.name }}</code>,
        <code>{{ invoice.reference }}</code>, <code>{{ invoice.amount_total|money }}</code>.
        Top-level: <code>account</code>, <code>contractor</code>, <code>invoice</code>
        (with <code>invoice.originated</code> / <code>invoice.terminated</code> / <code>invoice.services</code>),
        and the row collections
        <code>originated_destinations</code>, <code>originated_destinations_succ</code>,
        <code>terminated_destinations(_succ)</code>, <code>originated_networks(_succ)</code>,
        <code>terminated_networks(_succ)</code>, <code>service_data</code>.
        Filters: <code>money</code>, <code>number:N</code>,
        <code>duration:"colon"|"min"|"human"</code>, <code>strfdate:"%d.%m.%Y"</code>.
      HTML
    end
    panel 'ODT scalar placeholders (legacy)' do
      text_node 'This list of placeholders you can use anywhere in an ODT template'.html_safe
      table_for BillingInvoice::GenerateDocument.replaces_list.each do |_x|
        column :placeholder do |c|
          strong do
            "[#{c.to_s.upcase}]"
          end
        end
        column :description do |c|
          I18n.t('invoice_template.placeholders.' + c.to_s)
        end
      end
    end
  end

  show do |t|
    attributes_table do
      row :id
      row :name
      row('Type') { t.html_template.present? ? 'HTML' : 'ODT' }
      row :sha1
      row :created_at
    end

    if t.html_template.present?
      panel 'HTML template' do
        # Rendered as <pre><code class="language-django">; highlight.js (loaded
        # in active_admin.js) highlights it on load and adds `.hljs`, themed for
        # dark mode by the app CSS. The django/jinja grammar sub-highlights the
        # HTML (via xml) AND the pongo2 {{ }} / {% %} / {# #} tags. Arbre
        # HTML-escapes the String, so it's shown as source, not rendered.
        pre(style: 'white-space: pre-wrap; word-break: break-word;') do
          code(class: 'language-django') { t.html_template }
        end
      end
    end

    active_admin_comments
  end
end
