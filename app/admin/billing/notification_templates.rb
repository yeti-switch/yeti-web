# frozen_string_literal: true

ActiveAdmin.register Billing::NotificationTemplate do
  menu parent: %w[Billing Settings], label: 'Notification templates', priority: 91
  config.batch_actions = false

  # One row per event is seeded and must always exist, so rows can be edited but
  # never created or destroyed.
  actions :index, :show, :edit, :update

  permit_params :subject, :body

  filter :event, as: :select, collection: Billing::NotificationTemplate::CONST::EVENTS, input_html: { class: 'tom-select' }

  # Renders the template against sample data so a broken layout is visible before
  # it reaches a customer. The rendered body is untrusted admin HTML, so it goes
  # through the same sandboxed iframe used to display email logs — see
  # SandboxedEmailFrame for why.
  member_action :preview, method: :get do
    html = Liquid::Template
           .parse(resource.body, error_mode: :strict)
           .render!(BalanceNotificationMail.sample_assigns.deep_stringify_keys)

    render html: SandboxedEmailFrame.render(html, style: 'width:100%;height:98vh'), layout: false
  rescue StandardError => e
    flash[:warning] = "Template cannot be rendered: #{e.message}"
    redirect_to action: :show
  end

  action_item :preview, only: [:show] do
    link_to 'Preview', preview_billing_notification_template_path(resource), target: '_blank', rel: 'noopener'
  end

  index do
    id_column
    column :event
    column :subject
  end

  show do
    attributes_table do
      row :id
      row :event
      row :subject
      row :body do |t|
        pre t.body
      end
    end

    panel 'Available variables' do
      para 'Templates are rendered with liquid. Only the variables below are available; ' \
           'nothing else about the account can be referenced.'
      table_for BalanceNotificationMail.variable_reference do
        column('Variable') { |r| code "{{ #{r[:name]} }}" }
        column('Example') { |r| r[:example] }
      end
      para 'Email clients are not browsers: use inline styles and table layout only, ' \
           'and keep the alert legible without images.'
      para 'There is no packaged fallback: this row is the only source of the email.'
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :event, input_html: { disabled: true }
      f.input :subject
      f.input :body, as: :text, input_html: { rows: 25, style: 'font-family: monospace;' }
    end
    f.actions
  end
end
