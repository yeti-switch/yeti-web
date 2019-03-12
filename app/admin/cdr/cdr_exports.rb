# frozen_string_literal: true

ActiveAdmin.register CdrExport, as: 'CDR Export' do
  menu parent: 'CDR', priority: 97
  actions :index, :show, :create, :new

  filter :status, as: :select, collection: CdrExport::STATUSES
  filter :callback_url
  filter :created_at

  action_item(:download, only: [:show]) do
    link_to 'Download', action: :download if resource.completed?
  end

  action_item(:delete_file, only: [:show]) do
    link_to('Delete File', { action: :delete_file }, method: :delete) if resource.completed?
  end

  index do
    selectable_column
    id_column
    column :download do |row|
      link_to 'download', action: :download, id: row.id if row.completed?
    end
    column :status
    column :rows_count
    column :fields
    column :filters
    column :callback_url
    column :created_at
    column :updated_at
    actions
  end

  member_action :download do
    response.headers['X-Accel-Redirect'] = "/x-redirect/cdr_export/#{resource.id}.csv"
    response.headers['Content-Type'] = 'text/csv; charset=utf-8'
    response.headers['Content-Disposition'] = "attachment; filename=\"#{resource.id}.csv\""

    render body: nil
  end

  member_action :delete_file, method: :delete do
    resource.update!(status: CdrExport::STATUS_DELETED)
    flash[:notice] = 'The file will be deleted in background!'
    redirect_back fallback_location: root_path
  end

  controller do
    def build_new_resource
      build_params = resource_params[0].to_h
      return super unless build_params.any?

      # build filters
      filters = {}
      filters['time_start_gteq'] = build_params['time_start_gteq']
      filters['time_start_lteq'] = build_params['time_start_lteq']
      filters['customer_acc_id_eq'] = build_params['customer_acc_id_eq'] if build_params['customer_acc_id_eq'].present?
      filters['is_last_cdr_eq'] = build_params['is_last_cdr_eq'] == 'true' if build_params['is_last_cdr_eq'].present?
      scoped_collection.send method_for_build, build_params.merge(filters: filters)
    end
  end

  permit_params :time_start_gteq, :time_start_lteq,
                :customer_acc_id_eq, :is_last_cdr_eq, fields: []
  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :fields, as: :select, multiple: true, collection: CdrExport.allowed_fields, input_html: { class: 'chosen' }
    end
    f.inputs('Filters') do
      f.input 'time_start_gteq', as: :date_time_picker
      f.input :time_start_lteq, as: :date_time_picker
      f.input :customer_acc_id_eq, as: :select, collection: Account.order(:name), input_html: { class: 'chosen' }
      f.input :is_last_cdr_eq, as: :select, collection: [['Any', nil], ['Yes', true], ['No', false]], input_html: { class: 'chosen' }
    end
    f.actions
  end
end
