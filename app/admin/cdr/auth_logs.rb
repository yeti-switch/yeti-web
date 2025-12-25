# frozen_string_literal: true

ActiveAdmin.register Cdr::AuthLog, as: 'AuthLog' do
  menu parent: 'CDR', label: 'Auth Logs', priority: 10

  actions :index, :show
  config.batch_actions = false
  config.sort_order = 'request_time_desc'

  with_default_params do
    params[:q] = { request_time_gteq_datetime_picker: 0.days.ago.beginning_of_day }
    'Only records from beginning of the day showed by default'
  end

  acts_as_export :id,
                 :request_time,
                 [:gateway_name, proc { |row| row.gateway.try(:name) }],
                 [:node_name, proc { |row| row.node.try(:name) }],
                 [:pop_name, proc { |row| row.pop.try(:name) }],
                 :transport_protocol_name,
                 :transport_remote_ip,
                 :transport_remote_port,
                 :transport_local_ip,
                 :transport_local_port,
                 :origination_protocol_name,
                 :origination_ip,
                 :origination_port,
                 :username,
                 :realm,
                 :request_method,
                 :ruri,
                 :from_uri,
                 :to_uri,
                 :call_id,
                 :success,
                 :code,
                 :reason,
                 :internal_reason,
                 :auth_error_name,
                 :nonce,
                 :response,
                 :x_yeti_auth,
                 :diversion,
                 :pai,
                 :ppi,
                 :privacy,
                 :rpid,
                 :rpid_privacy

  scope :all, show_count: false
  scope :successful, show_count: false
  scope :failed, show_count: false

  controller do
    def scoped_collection
      super.preload(:gateway, :pop, :node)
    end
  end

  index do
    id_column
    column :request_time
    column :gateway

    column :success
    column :code
    column :reason
    column :internal_reason
    column :auth_error, &:auth_error_name

    column :originator do |c|
      "#{c.origination_protocol_name}://#{c.origination_ip}:#{c.origination_port}"
    end

    column :remote_socket do |c|
      "#{c.transport_protocol_name}://#{c.transport_remote_ip}:#{c.transport_remote_port}"
    end

    column :local_socket do |c|
      "#{c.transport_local_ip}:#{c.transport_local_port}"
    end

    column :pop
    column :node

    column :username
    column :realm

    column :request_method
    column :ruri
    column :from_uri
    column :to_uri
    column :call_id

    column :nonce
    column :response
    column :x_yeti_auth
    column :diversion
    column :pai
    column :ppi
    column :privacy
    column :rpid
    column :rpid_privacy
  end

  filter :id
  filter :request_time, as: :date_time_range
  filter :gateway,
         input_html: { class: 'chosen-ajax', 'data-path': '/gateways/search' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:gateway_id_eq]
           resource_id ? Gateway.where(id: resource_id) : []
         }

  filter :pop
  filter :node
  filter :username
  filter :origination_proto_id_eq, label: 'Origination protocol', as: :select, collection: Cdr::AuthLog::TRANSPORT_PROTOCOLS.invert
  filter :origination_ip_covers,
         as: :string,
         input_html: { class: 'search_filter_string' },
         label: 'Origination IP'

  filter :transport_proto_id_eq, label: 'Transport protocol', as: :select, collection: Cdr::AuthLog::TRANSPORT_PROTOCOLS.invert
  filter :transport_remote_ip_covers,
         as: :string,
         input_html: { class: 'search_filter_string' },
         label: 'Transport remote IP'

  filter :transport_local_ip_covers,
         as: :string,
         input_html: { class: 'search_filter_string' },
         label: 'Transport local IP'

  filter :ruri
  filter :from_uri
  filter :to_uri
  filter :call_id
  filter :code
  filter :reason
  filter :internal_reason
  filter :auth_error_id_eq,
         label: 'Auth Error',
         as: :select,
         collection: Cdr::AuthLog::AUTH_ERRORS.invert,
         input_html: { class: :chosen }

  filter :realm
  filter :request_method
  filter :x_yeti_auth
  filter :diversion
  filter :pai
  filter :ppi
  filter :privacy
  filter :rpid
  filter :rpid_privacy
end
