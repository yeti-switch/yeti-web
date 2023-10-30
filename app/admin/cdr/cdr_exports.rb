# frozen_string_literal: true

ActiveAdmin.register CdrExport, as: 'CDR Export' do
  menu parent: 'CDR', priority: 97
  actions :index, :show, :create, :new

  acts_as_clone

  controller do
    def scoped_collection
      super.preload(:customer_account)
    end

    def build_new_resource
      record = super
      if params[:action] == 'new'
        record.fields = CdrExport.last&.fields || []
      end
      record
    end
  end

  filter :id
  filter :status, as: :select, collection: CdrExport::STATUSES
  filter :rows_count
  account_filter :customer_account, path_params: { q: { contractor_customer_eq: true } }
  filter :callback_url
  filter :created_at
  filter :updated_at
  filter :uuid_equals, label: 'UUID'

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
    column :customer_account
    column :callback_url
    column :created_at
    column :updated_at
    column :uuid
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
          row :customer_account
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
    response.headers['X-Accel-Redirect'] = "/x-redirect/cdr_export/#{resource.id}.csv.gz"
    response.headers['Content-Type'] = 'text/csv; charset=utf-8'
    response.headers['Content-Disposition'] = "attachment; filename=\"#{resource.id}.csv.gz\""

    render body: nil
  end

  member_action :delete_file, method: :delete do
    resource.update!(status: CdrExport::STATUS_DELETED)
    flash[:notice] = 'The file will be deleted in background!'
    redirect_back fallback_location: root_path
  end

  permit_params :callback_url,
                filters: [
                  :time_start_gteq,
                  :time_start_lteq,
                  :time_start_lt,
                  :customer_id_eq,
                  :customer_external_id_eq,
                  :customer_acc_id_eq,
                  :customer_acc_external_id_eq,
                  :vendor_id_eq,
                  :vendor_external_id_eq,
                  :vendor_acc_id_eq,
                  :vendor_acc_external_id_eq,
                  :is_last_cdr_eq,
                  :success_eq,
                  :customer_auth_id_eq,
                  :customer_auth_external_id_eq,
                  :failed_resource_type_id_eq,
                  :src_prefix_in_contains,
                  :src_prefix_in_eq,
                  :dst_prefix_in_contains,
                  :dst_prefix_in_eq,
                  :src_prefix_routing_contains,
                  :src_prefix_routing_eq,
                  :dst_prefix_routing_contains,
                  :dst_prefix_routing_eq,
                  :src_prefix_out_contains,
                  :src_prefix_out_eq,
                  :dst_prefix_out_contains,
                  :dst_prefix_out_eq,
                  :src_country_id_eq,
                  :dst_country_id_eq,
                  :routing_tag_ids_include,
                  :routing_tag_ids_exclude,
                  :routing_tag_ids_empty,
                  :orig_gw_id_eq,
                  :orig_gw_external_id_eq,
                  :term_gw_id_eq,
                  :term_gw_external_id_eq,
                  :duration_eq,
                  :duration_gteq,
                  :duration_lteq,
                  :customer_auth_external_type_eq,
                  :customer_auth_external_type_not_eq,
                  customer_auth_external_id_in: [],
                  dst_country_iso_in: [],
                  src_country_iso_in: []
                ],
                fields: []

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs do
      f.input :fields,
              as: :select,
              multiple: true,
              collection: CdrExport.allowed_fields,
              input_html: { class: 'chosen' },
              required: true

      f.input :callback_url, required: false
    end
    f.inputs 'Filters', for: [:filters, f.object.filters] do |ff|
      # accounts = Account.order(:name)
      gateways = Gateway.order(:name)
      boolean_options = [['Any', nil], ['Yes', true], ['No', false]]

      ff.input :time_start_gteq, as: :date_time_picker, required: true
      ff.input :time_start_lteq, as: :date_time_picker, required: false
      ff.input :time_start_lt, as: :date_time_picker, required: false

      ff.contractor_input :customer_id_eq,
                          label: 'Customer id eq',
                          path_params: { q: { customer_eq: true } }

      ff.input :customer_external_id_eq, required: false

      ff.account_input :customer_acc_id_eq,
                       label: 'Customer acc id eq',
                       path_params: { q: { contractor_customer_eq: true } }

      ff.input :customer_acc_external_id_eq, required: false

      ff.input :success_eq,
               as: :select,
               collection: boolean_options,
               input_html: { class: 'chosen' },
               required: false

      ff.input :duration_eq, as: :number
      ff.input :duration_lteq, as: :number
      ff.input :duration_gteq, as: :number

      ff.input :failed_resource_type_id_eq, required: false

      ff.contractor_input :vendor_id_eq,
                          label: 'Vendor id eq',
                          path_params: { q: { vendor_eq: true } }
      ff.input :vendor_external_id_eq, required: false

      ff.account_input :vendor_acc_id_eq,
                       label: 'Vendor acc id eq',
                       path_params: { q: { contractor_vendor_eq: true } }
      ff.input :vendor_acc_external_id_eq, required: false

      ff.input :customer_auth_id_eq,
               as: :select,
               collection: CustomersAuth.order(:name),
               input_html: { class: 'chosen' },
               required: false
      ff.input :customer_auth_external_id_eq, required: false

      ff.input :is_last_cdr_eq,
               as: :select,
               collection: boolean_options,
               input_html: { class: 'chosen' },
               required: false

      ff.input :src_prefix_in_contains, required: false
      ff.input :src_prefix_in_eq, required: false
      ff.input :src_prefix_routing_contains, required: false
      ff.input :src_prefix_routing_eq, required: false
      ff.input :src_prefix_out_contains, required: false
      ff.input :src_prefix_out_eq, required: false

      ff.input :dst_prefix_in_contains, required: false
      ff.input :dst_prefix_in_eq, required: false
      ff.input :dst_prefix_routing_contains, required: false
      ff.input :dst_prefix_routing_eq, required: false
      ff.input :dst_prefix_out_contains, required: false
      ff.input :dst_prefix_out_eq, required: false

      ff.input :src_country_id_eq,
               as: :select,
               collection: System::Country.all,
               input_html: { class: 'chosen' },
               required: false
      ff.input :dst_country_id_eq,
               as: :select,
               collection: System::Country.all,
               input_html: { class: 'chosen' },
               required: false

      ff.input :routing_tag_ids_include, required: false
      ff.input :routing_tag_ids_exclude, required: false
      ff.input :routing_tag_ids_empty,
               as: :select,
               collection: boolean_options,
               input_html: { class: 'chosen' },
               required: false

      ff.input :orig_gw_id_eq,
               as: :select,
               collection: gateways,
               input_html: { class: 'chosen' },
               required: false
      ff.input :orig_gw_external_id_eq, required: false

      ff.input :term_gw_id_eq,
               as: :select,
               collection: gateways,
               input_html: { class: 'chosen' },
               required: false
      ff.input :term_gw_external_id_eq, required: false
      ff.input :customer_auth_external_type_eq, required: false
      ff.input :customer_auth_external_type_not_eq, required: false
      ff.input :customer_auth_external_id_in,
               as: :select,
               multiple: true,
               required: false,
               input_html: {
                 class: 'chosen-ajax',
                 data: {
                   path: '/customers_auths/search_with_return_external_id?q[ordered_by]=name'
                 }
               },
               collection: if params.dig(:q, :customer_auth_external_id_in)
                             CustomersAuth.where(external_id: params.dig(:q, :customer_auth_external_id_in)).order(:name).pluck(:name, :external_id)
                           else
                             CustomersAuth.none
                           end
      ff.input :src_country_iso_in,
               as: :select,
               multiple: true,
               collection: System::Country.pluck(:name, :iso2),
               input_html: { class: 'chosen' },
               required: false
      ff.input :dst_country_iso_in,
               as: :select,
               multiple: true,
               collection: System::Country.pluck(:name, :iso2),
               input_html: { class: 'chosen' },
               required: false
    end
    f.actions
  end
end
