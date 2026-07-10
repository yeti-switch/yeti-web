# frozen_string_literal: true

ActiveAdmin.register Billing::InvoiceTemplate, as: 'InvoiceTemplate' do
  menu parent: %w[Billing Settings], label: 'Invoice templates', priority: 90
  config.batch_actions = false
  actions :all # :index,:create, :new, :destroy, :delete, :edit, :update
  # `before_action :left_sidebar!` removed with the active_admin_sidebar gem;
  # ActiveAdmin 4 has no sidebar-position option.

  permit_params :name, :html_template

  acts_as_export :id, :name, :created_at

  controller do
    def scoped_collection
      # keep the (potentially large) html_template out of the index listing
      super.select('created_at, id, name')
    end

    def find_resource
      scoped_collection.except(:select).find(params[:id])
    end
  end

  action_item :playground, only: :show do
    action_item_link 'Template Playground', template_playground_path(template_id: resource.id)
  end

  index do
    id_column
    actions
    column :name
    column :created_at
  end

  filter :id, as: :numeric
  filter :name

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :html_template, as: :text, input_html: { rows: 24 }
    end
    f.actions
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

    active_admin_comments_for(resource)
  end
end
