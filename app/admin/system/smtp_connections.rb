# frozen_string_literal: true

ActiveAdmin.register System::SmtpConnection do
  menu parent: 'System', label: 'SMTP connections', priority: 150
  config.batch_actions = false

  permit_params :name, :host, :port, :from_address, :auth_user, :auth_password, :global, :auth_type

  filter :id
  filter :name
  filter :auth_type, as: :select, collection: System::SmtpConnection::CONST::AUTH_TYPES

  member_action :send_email, method: :post do
    begin
      SmtpConnectionMail.test_message(resource, params[:email]).deliver!
      flash[:notice] = 'Mail was sent successfully'
    rescue StandardError => e
      Rails.logger.warn { e.message }
      Rails.logger.warn { e.backtrace.join("\n") }
      CaptureError.capture(e, tags: { component: 'AdminUI' }, extra: { params: params.to_unsafe_h })
      flash[:warning] = e.message
    end
    redirect_back fallback_location: root_path
  end

  index do
    id_column
    column :name
    column :host
    column :port
    column :from_address
    column :auth_user
    column :auth_type
    column :global
  end

  sidebar :test, only: [:show] do
    active_admin_form_for(OpenStruct.new(to: '', subject: '', body: ''),
                          as: :email,
                          url: send_email_system_smtp_connection_path) do |f|
      f.inputs do
        f.input :to, as: :string, input_html: { style: 'width: 200px' }
        f.input :subject, input_html: { style: 'width: 200px' }
        f.input :body, input_html: { style: 'width: 200px' }
      end
      f.actions
    end
  end

  show do |_s|
    attributes_table do
      row :id
      row :name
      row :host
      row :port
      row :from_address
      row :auth_user
      row :auth_password, class: 'password-mask'
      row :auth_type
      row :global
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :host
      f.input :port
      f.input :from_address
      f.input :auth_user
      f.input :auth_password, as: :string, wrapper_html: { class: 'password-mask' }
      f.input :auth_type, as: :select, collection: System::SmtpConnection::CONST::AUTH_TYPES
      f.input :global
    end
    f.actions
  end
end
