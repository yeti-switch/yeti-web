ActiveAdmin.register Cdr::AuthLog, as: 'AuthLog' do
  menu parent: "CDR", label: "Auth Logs", priority: 10

  actions :index, :show
  config.batch_actions = false
  config.sort_order = 'request_time_desc'

  scope :all, show_count: false
  scope :successful, show_count: false
  scope :failed, show_count: false

  includes :gateway, :pop, :node, :transport_protocol, :origination_protocol

  index do
    id_column
    column :request_time
    column :gateway

    column :success
    column :code
    column :reason
    column :internal_reason

    column :originator do |c|
      "#{c.origination_protocol.display_name}://#{c.origination_ip}:#{c.origination_port}"
    end

    column :remote_socket do |c|
      "#{c.transport_protocol.display_name}://#{c.transport_remote_ip}:#{c.transport_remote_port}"
    end

    column :local_socket do |c|
      "#{c.transport_local_ip}:#{c.transport_local_port}"
    end

    column :pop
    column :node

    column :username

    column :method
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
  filter :gateway
  filter :pop
  filter :node
  filter :username

end
