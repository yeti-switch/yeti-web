# frozen_string_literal: true

ActiveAdmin.register Lnp::Database do
  menu parent: 'Equipment', priority: 95, label: 'LNP Databases'
  config.remove_action_item(:new)

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  acts_as_export :id, :name

  action_item :new_databases, only: [:index] do
    dropdown_menu 'New Lnp Database' do
      item Lnp::Database::CONST::TYPE_NAME_THINQ,
           action: :new,
           lnp_database: { database_type: Lnp::Database::CONST::TYPE_THINQ }
      item Lnp::Database::CONST::TYPE_NAME_SIP_REDIRECT,
           action: :new,
           lnp_database: { database_type: Lnp::Database::CONST::TYPE_SIP_REDIRECT }
      item Lnp::Database::CONST::TYPE_NAME_CSV,
           action: :new,
           lnp_database: { database_type: Lnp::Database::CONST::TYPE_CSV }
      item Lnp::Database::CONST::TYPE_NAME_ALCAZAR,
           action: :new,
           lnp_database: { database_type: Lnp::Database::CONST::TYPE_ALCAZAR }
      item Lnp::Database::CONST::TYPE_NAME_COURE_ANQ,
           action: :new,
           lnp_database: { database_type: Lnp::Database::CONST::TYPE_COURE_ANQ }
    end
  end

  before_action only: [:new] do
    database_type = params.dig(:lnp_database, :database_type)
    if Lnp::Database::CONST::TYPES.keys.exclude?(database_type)
      flash[:error] = "invalid database type #{database_type.inspect}"
      redirect_to lnp_databases_path
    end
  end

  member_action :test_resolve, method: :post do
    begin
      resolved = resource.test_db(params['dst']['dst'])
      flash[:notice] = "Database: #{resource.name} Destination: #{params['dst']['dst']} LRN: #{resolved.lrn}, TAG: #{resolved.tag}"
    rescue StandardError => e
      Rails.logger.warn { e.message }
      Rails.logger.warn { e.backtrace.join("\n") }
      CaptureError.capture(e, tags: { component: 'AdminUI' }, extra: { params: params.to_unsafe_h })
      flash[:warning] = e.message
    end
    redirect_back fallback_location: root_path
  end

  index disable_blank_slate_link: true do
    selectable_column
    id_column
    actions
    column :name
    column :type, :database_type_name, sortable: :database_type
    column :cache_ttl
    column :created_at
  end

  filter :id
  filter :name

  filter :database_type,
         label: 'Type',
         input_html: { class: 'tom-select' },
         collection: Lnp::Database::CONST::TYPES.invert.to_a

  filter :created_at

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

  show do
    columns do
      column do
        attributes_table do
          row :id
          row :name
          row :cache_ttl
          row :created_at
        end
      end

      column do
        panel resource.database_type_name do
          attributes_table_for resource.database do
            case resource.database_type
            when Lnp::Database::CONST::TYPE_THINQ
              row :host
              row :plain_http
              row :port
              row :timeout
              row :username
              row :token
            when Lnp::Database::CONST::TYPE_SIP_REDIRECT
              row :format
              row :host
              row :port
              row :timeout
            when Lnp::Database::CONST::TYPE_CSV
              row :csv_file_path
            when Lnp::Database::CONST::TYPE_ALCAZAR
              row :host
              row :port
              row :key
              row :timeout
            when Lnp::Database::CONST::TYPE_COURE_ANQ
              row :base_url
              row :username
              row :password
              row :country_code
              row :operators_map
              row :timeout
            end
          end
        end
      end
    end
  end

  permit_params do
    attrs = %i[name database_type cache_ttl]
    database_attrs = [:type]
    database_type = params[:lnp_database].try!(:[], :database_type) ||
                    params[:lnp_database].try!(:[], :database_attributes).try!(:[], :type)

    case database_type
    when Lnp::Database::CONST::TYPE_THINQ
      database_attrs += %i[host plain_http port username token timeout]
    when Lnp::Database::CONST::TYPE_SIP_REDIRECT
      database_attrs += %i[host port timeout format_id]
    when Lnp::Database::CONST::TYPE_CSV
      database_attrs += [:csv_file_path]
    when Lnp::Database::CONST::TYPE_ALCAZAR
      database_attrs += %i[host port key timeout]
    when Lnp::Database::CONST::TYPE_COURE_ANQ
      database_attrs += %i[base_url username password country_code operators_map timeout]
    end

    # get_resource_ivar&.persisted? # if persisted
    attrs + [database_attributes: database_attrs]
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs name: 'Main' do
      f.input :name
      f.input :cache_ttl
    end

    database = f.object.database || f.object.database_type.constantize.new
    f.inputs name: f.object.database_type_name, for: [:database, database] do |o|
      o.input :type, as: :hidden, input_html: { value: f.object.database_type }

      case f.object.database_type
      when Lnp::Database::CONST::TYPE_THINQ
        o.input :host
        o.input :plain_http
        o.input :port
        o.input :username
        o.input :token
        o.input :timeout
      when Lnp::Database::CONST::TYPE_SIP_REDIRECT
        o.input :format, as: :select, include_blank: false, input_html: { class: 'tom-select' }
        o.input :host
        o.input :port
        o.input :timeout
      when Lnp::Database::CONST::TYPE_CSV
        o.input :csv_file_path
      when Lnp::Database::CONST::TYPE_ALCAZAR
        o.input :host
        o.input :port
        o.input :key
        o.input :timeout
      when Lnp::Database::CONST::TYPE_COURE_ANQ
        o.input :base_url
        o.input :username
        o.input :password, as: :string
        o.input :country_code
        o.input :operators_map
        o.input :timeout
      end
    end

    actions
  end
end
