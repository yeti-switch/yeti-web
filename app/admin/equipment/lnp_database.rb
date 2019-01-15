# frozen_string_literal: true

ActiveAdmin.register Lnp::Database do
  menu parent: 'Equipment', priority: 95, label: 'LNP Databases'

  # acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  acts_as_export :id, :name

  permit_params :name, :driver_id, :host, :port, :thinq_token, :thinq_username, :timeout, :csv_file

  includes :driver

  member_action :test_resolve, method: :post do
    begin
      resolved = resource.test_db(params['dst']['dst'])
      flash[:notice] = "Database: #{resource.name} Destination: #{params['dst']['dst']} LRN: #{resolved.lrn}, TAG: #{resolved.tag}"
    rescue StandardError => e
      Rails.logger.warn { e.message }
      Rails.logger.warn { e.backtrace.join("\n") }
      flash[:warning] = e.message
    end
    redirect_back fallback_location: root_path
  end

  index do
    selectable_column
    id_column
    actions
    column :name
    column :driver
    column :host
    column :port
    column :timeout
    column :created_at
  end

  filter :id
  filter :name

  sidebar :test, only: [:show] do
    active_admin_form_for(OpenStruct.new(dst: ''),
                          as: :dst,
                          url: test_resolve_lnp_database_path) do |f|
      f.inputs do
        f.input :dst, as: :string, input_html: { style: 'width: 200px' }
      end
      f.actions
    end
  end

  show do |_s|
    attributes_table do
      row :id
      row :name
      row :driver
      row :host
      row :port
      row :timeout
      row :thinq_username
      row :thinq_token
      row :csv_file
      row :created_at
    end
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :driver
      f.input :host # , input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::SIP}
      f.input :port # , input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::SIP}
      f.input :timeout, hint: 'Request timeout in ms.' # , input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::SIP}
      f.input :thinq_username # , input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::THINQ}
      f.input :thinq_token # , input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::THINQ}
      f.input :csv_file # , input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::INMEMORY}
    end
    actions
  end
end
