# frozen_string_literal: true

ActiveAdmin.register CdrExport, as: 'CDR Export' do
  menu parent: 'CDR', priority: 97
  actions :index, :show, :create, :new

  filter :id
  filter :status, as: :select, collection: CdrExport::STATUSES
  filter :rows_count
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
    column :filters do |r|
      r.filters.as_json
    end
    column :callback_url
    column :created_at
    column :updated_at
    actions
  end

  #  id           :integer          not null, primary key
  #  status       :string           not null
  #  fields       :string           default([]), not null, is an Array
  #  filters      :json             not null
  #  callback_url :string
  #  type         :string           not null
  #  created_at   :datetime
  #  updated_at   :datetime
  #  rows_count   :integer
  show do
    columns do
      column do
        attributes_table do
          row :id
          row :status
          row :callback_url
          row :type
          row :created_at
          row :updated_at
          row :rows_count
        end
        active_admin_comments
      end

      column do
        panel 'Fields' do
          ul do
            resource.fields.each { |field| li field }
          end
        end
        panel 'Filters' do
          attributes_table_for(resource.filters, *CdrExport::FiltersModel.attribute_types.keys)
        end
      end
    end
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
      record = super
      if params[:action] == 'new'
        record.fields = CdrExport.last&.fields || []
      end
      record
    end
  end

  permit_params filters: %i[time_start_gteq
                            time_start_lteq
                            customer_acc_id_eq
                            is_last_cdr_eq
                            src_prefix_in_contains
                            src_prefix_routing_contains
                            src_prefix_out_contains
                            dst_prefix_in_contains
                            dst_prefix_routing_contains
                            dst_prefix_out_contains],
                fields: []

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :fields,
              as: :select,
              multiple: true,
              collection: CdrExport.allowed_fields,
              input_html: { class: 'chosen' }
    end
    f.inputs 'Filters', for: [:filters, f.object.filters] do |ff|
      ff.input :time_start_gteq, as: :date_time_picker
      ff.input :time_start_lteq, as: :date_time_picker

      ff.input :customer_acc_id_eq,
               as: :select,
               collection: Account.order(:name),
               input_html: { class: 'chosen' }

      ff.input :is_last_cdr_eq,
               as: :select,
               collection: [['Any', nil], ['Yes', true], ['No', false]],
               input_html: { class: 'chosen' }

      ff.input :src_prefix_in_contains, required: false
      ff.input :src_prefix_routing_contains, required: false
      ff.input :src_prefix_out_contains, required: false

      ff.input :dst_prefix_in_contains, required: false
      ff.input :dst_prefix_routing_contains, required: false
      ff.input :dst_prefix_out_contains, required: false
    end
    f.actions
  end
end
