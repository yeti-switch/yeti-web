# frozen_string_literal: true

ActiveAdmin.register Billing::NotificationTemplate do
  menu parent: %w[Billing Settings], label: 'Notification templates', priority: 92
  config.batch_actions = false

  actions :index, :show, :edit, :update

  permit_params :subject, :body

  filter :event, as: :select, collection: Billing::NotificationTemplate::CONST::EVENTS, input_html: { class: 'tom-select' }

  member_action :preview, method: :get do
    html = resource.render_body(BalanceNotificationMail.sample_assigns)

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
