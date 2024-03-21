# frozen_string_literal: true

ActiveAdmin.register Log::ApiLog, as: 'ApiLog' do
  decorate_with ApiLogDecorator
  menu parent: 'Logs', priority: 1, label: 'API log'
  config.batch_actions = false
  actions :index, :show

  scope :all, default: true
  scope :failed, show_count: false

  with_default_params do
    params[:q] = { created_at_gteq_datetime_picker: 0.days.ago.beginning_of_day } # only 1 last days by default
    'Only records from beginning of the day showed by default'
  end

  controller do
    def scoped_collection
      super.select('id, created_at, status, method, path, db_duration, page_duration, remote_ip, tags')
    end

    def find_resource
      scoped_collection.except(:select).send(method_for_find, params[:id])
    end
  end

  filter :id
  filter :created_at, as: :date_time_range
  filter :path
  filter :method
  filter :tag_eq, label: 'Tag Equals'
  filter :status
  filter :controller, as: :select, collection: proc { ApiControllers.list }, input_html: { class: :chosen }
  filter :action
  filter :page_duration
  filter :db_duration
  filter :params
  filter :request_body
  filter :response_body
  filter :request_headers
  filter :response_headers
  filter :remote_ip_eq_inet, as: :string, label: 'Remote IP'

  index download_links: false do
    id_column
    column :created_at
    column :status
    column :method
    column :tags, &:tags_separated_by_comma
    column :path
    column :db_duration
    column :page_duration
    column :remote_ip
  end

  show do
    attributes_table do
      row :id
      row :created_at
      row :status
      row :method
      row :tags, &:tags_separated_by_comma
      row :path
      row :controller
      row :action
      row :page_duration
      row :db_duration
      row :params do |l|
        pre do
          l.params
        end
      end
      row :request_headers do |l|
        pre do
          l.request_headers
        end
      end
      row :request_body do |l|
        pre do
          l.request_body
        end
      end
      row :response_headers do |l|
        pre do
          l.response_headers
        end
      end
      row :response_body do |l|
        pre do
          l.response_body
        end
      end
      row :meta do |l|
        pre do
          l.meta
        end
      end
      row :remote_ip
    end
    active_admin_comments
  end
end
