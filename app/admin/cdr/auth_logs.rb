# frozen_string_literal: true

ActiveAdmin.register Cdr::AuthLog, as: 'AuthLog' do
  menu parent: 'CDR', label: 'Auth Logs', priority: 10

  actions :index, :show
  config.batch_actions = false
  config.sort_order = 'request_time_desc'

  with_default_params do
    params[:q] = { request_time_gteq_datetime: 1.days.ago.to_date.strftime('%F') }
    'Only records from yesterday are displayed by default'
  end

  acts_as_export :id,
                 :request_time,
                 [:gateway_name, proc { |row| row.gateway.try(:name) }],
                 [:node_name, proc { |row| row.node.try(:name) }],
                 [:pop_name, proc { |row| row.pop.try(:name) }],
                 [:transport_protocol, proc { |row| row.transport_protocol.try(:name) }],
                 :transport_remote_ip,
                 :transport_remote_port,
                 :transport_local_ip,
                 :transport_local_port,
                 [:origination_protocol, proc { |row| row.origination_protocol.try(:name) }],
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
      super.preload(:gateway, :pop, :node, :transport_protocol, :origination_protocol)
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

    column :originator do |c|
      "#{c.origination_protocol.try(:display_name)}://#{c.origination_ip}:#{c.origination_port}"
    end

    column :remote_socket do |c|
      "#{c.transport_protocol.try(:display_name)}://#{c.transport_remote_ip}:#{c.transport_remote_port}"
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
  filter :request_time
  filter :gateway,
         input_html: { class: 'chosen-ajax', 'data-path': '/gateways/search' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:gateway_id_eq]
           resource_id ? Gateway.where(id: resource_id) : []
         }

  filter :pop
  filter :node
  filter :username
  filter :origination_ip
  filter :transport_remote_ip
  filter :transport_local_ip
  filter :ruri
  filter :from_uri
  filter :to_uri
  filter :call_id
end
