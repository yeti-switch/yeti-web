# frozen_string_literal: true

ActiveAdmin.register Log::EmailLog do
  menu parent: 'Logs', priority: 140, label: 'Email Log'
  actions :index, :show
  config.batch_actions = false

  controller do
    def scoped_collection
      super.preload(:smtp_connection, contact: %i[contractor admin_user])
    end
  end

  member_action :export, method: :get do
    att = resource.getfile(params[:attachment])
    if att.present?
      send_data att.data, type: 'text/csv', filename: att.filename
    else
      flash[:warning] = 'Attachment not found'
      redirect_to log_email_logs_path
    end
  end

  index do
    id_column
    column :created_at
    column :sent_at
    column :contact
    column :smtp_connection
    column :mail_from
    column :mail_to
    column :subject
    # column :msg
    column 'Attachments' do |r|
      raw(r.attachments_no_data.map { |rg| link_to rg.basename, export_log_email_log_path(r, attachment: rg.id) }.sort.join(', '))
    end
    column :error
  end

  filter :id
  filter :batch_id
  filter :contact, collection: proc { Billing::Contact.includes(:contractor, :admin_user) }, input_html: { class: 'chosen' }
  filter :smtp_connection, input_html: { class: 'chosen' }
  filter :mail_to

  show do
    attributes_table do
      row :id
      row :created_at
      row :sent_at
      row :contact
      row :smtp_connection
      row :mail_from
      row :mail_to
      row :subject
      row :msg do |r|
        raw(r.msg)
      end
      row 'Attachments' do |r|
        raw(r.attachments_no_data.map { |rg| link_to rg.basename, export_log_email_log_path(r, attachment: rg.id) }.sort.join(', '))
      end
      row :error
    end
  end
end
