# frozen_string_literal: true

ActiveAdmin.register Cnam::Database do
  menu parent: 'Equipment', priority: 110, label: 'CNAM Databases'
  config.remove_action_item(:new)

  # acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  acts_as_export :id, :name

  action_item :new_databases, only: [:index] do
    dropdown_menu 'New CNAM Database' do
      item Cnam::Database::CONST::TYPE_NAME_HTTP,
           action: :new,
           cnam_database: { database_type: Cnam::Database::CONST::TYPE_HTTP }
    end
  end

  before_action only: [:new] do
    database_type = params.dig(:cnam_database, :database_type)
    if Cnam::Database::CONST::TYPES.keys.exclude?(database_type)
      flash[:error] = "invalid database type #{database_type.inspect}"
      redirect_to cnam_databases_path
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
    column :created_at
  end

  filter :id
  filter :name

  filter :database_type,
         label: 'Type',
         input_html: { class: :chosen },
         collection: Cnam::Database::CONST::TYPES.invert.to_a

  filter :created_at

  sidebar :test, only: [:show] do
    active_admin_form_for(OpenStruct.new(dst: ''),
                          as: :dst,
                          url: test_resolve_cnam_database_path) do |f|
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
          row :created_at
        end
      end

      column do
        panel resource.database_type_name do
          attributes_table_for resource.database do
            case resource.database_type
            when Cnam::Database::CONST::TYPE_HTTP
              row :url
              row :timeout
            end
          end
        end
      end
    end
  end

  permit_params do
    attrs = %i[name database_type]
    database_attrs = [:type]
    database_type = params[:cnam_database].try!(:[], :database_type) ||
      params[:cnam_database].try!(:[], :database_attributes).try!(:[], :type)

    case database_type
    when Cnam::Database::CONST::TYPE_HTTP
      database_attrs += %i[url timeout]
    end

    # get_resource_ivar&.persisted? # if persisted
    attrs + [database_attributes: database_attrs]
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs name: 'Main' do
      f.input :name
    end

    database = f.object.database || f.object.database_type.constantize.new
    f.inputs name: f.object.database_type_name, for: [:database, database] do |o|
      o.input :type, as: :hidden, input_html: { value: f.object.database_type }

      case f.object.database_type
      when Cnam::Database::CONST::TYPE_HTTP
        o.input :url
        o.input :timeout
      end
    end

    actions
  end
end
