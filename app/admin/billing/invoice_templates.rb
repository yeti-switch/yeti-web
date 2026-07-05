# frozen_string_literal: true

ActiveAdmin.register Billing::InvoiceTemplate, as: 'InvoiceTemplate' do
  menu parent: %w[Billing Settings], label: 'Invoice templates', priority: 90
  config.batch_actions = false
  actions :all # :index,:create, :new, :destroy, :delete, :edit, :update
  before_action :left_sidebar!

  permit_params :name, :html_template

  acts_as_export :id, :name, :created_at

  member_action :download, method: :get do
    send_data resource.html_template, type: 'text/html', filename: "#{resource.name}.html"
  end

  controller do
    def scoped_collection
      # keep the (potentially large) html_template out of the index listing
      super.select('created_at, id, name')
    end

    def find_resource
      scoped_collection.except(:select).find(params[:id])
    end
  end

  index do
    id_column
    actions
    column :name
    column 'File' do |row|
      link_to "#{row.name}.html", download_invoice_template_path(row), method: :get
    end
    column :created_at
  end

  filter :id, as: :numeric
  filter :name

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :html_template, as: :text, input_html: { rows: 24 },
                              hint: 'HTML/pongo2 template rendered to PDF by the yeti-pdf service (invoice.pdf_api must be configured).'
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
  end

  show do |t|
    attributes_table do
      row :id
      row :name
      row :created_at
    end

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

    active_admin_comments
  end
end
