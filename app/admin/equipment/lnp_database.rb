ActiveAdmin.register Lnp::Database do

  menu parent: 'Equipment', priority: 95, label: 'LNP Databases'

  #acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  acts_as_export :id, :name

  permit_params :name, :driver_id, :host, :port, :thinq_token, :thinq_username, :timeout, :csv_file

  includes :driver

  member_action :test, method: :post do
    begin
      lrn=Lnp::Database.find(resource)
      r=lrn.test_db(params['dst']['dst']) if lrn.present?
      flash[:notice] = "Database: #{lrn.name} Destination: #{params['dst']['dst']} LRN: #{r.lrn}, TAG: #{r.tag}"
    rescue StandardError => e
      Rails.logger.warn { e.message }
      Rails.logger.warn { e.backtrace.join("\n") }
      flash[:warning] = e.message
    end
    redirect_to :back
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
                          url: test_lnp_database_path

    ) do |f|
      f.inputs do
        f.input :dst, as: :string, input_html: {style: 'width: 200px'}
      end
      f.actions
    end

  end

  show do |s|
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
      f.input :name, hint: I18n.t('hints.equipment.lnp_database.name')
      f.input :driver, hint: I18n.t('hints.equipment.lnp_database.driver')
      f.input :host, hint: I18n.t('hints.equipment.lnp_database.host') #, input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::SIP}
      f.input :port, hint: I18n.t('hints.equipment.lnp_database.port') #, input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::SIP}
      f.input :timeout, hint: I18n.t('hints.equipment.lnp_database.timeout') #, input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::SIP}
      f.input :thinq_username, hint: I18n.t('hints.equipment.lnp_database.thinq_username') #, input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::THINQ}
      f.input :thinq_token, hint: I18n.t('hints.equipment.lnp_database.thinq_token') #, input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::THINQ}
      f.input :csv_file, hint: I18n.t('hints.equipment.lnp_database.csv_file') #, input_html: {'data-depend_selector' => '#lnp_database_driver_id', 'data-depend_value' => Lnp::DatabaseDriver::INMEMORY}
    end
    actions
  end

end
