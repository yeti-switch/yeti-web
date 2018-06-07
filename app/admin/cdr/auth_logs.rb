ActiveAdmin.register Cdr::AuthLog, as: 'AuthLog' do
  menu parent: "CDR", label: "Auth Logs", priority: 10

  actions :index, :show
  config.batch_actions = false
  config.sort_order = 'request_time_desc'

  includes :gateway, :pop, :node

  index do
    id_column
    column :request_time
    column :gateway
    column :pop
    column :node
    column :sign_orig_ip
    column :sign_orig_port
    column :sign_orig_local_ip
    column :sign_orig_local_port
    column :auth_orig_ip
    column :auth_orig_port
    column :ruri
    column :from_uri
    column :to_uri
    column :orig_call_id
    column :success
    column :code
    column :reason
    column :internal_reason
    column :nonce
    column :response
  end

  filter :id
  filter :request_time
  filter :gateway
  filter :pop
  filter :node

end
