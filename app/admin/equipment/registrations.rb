ActiveAdmin.register Equipment::Registration do

  menu parent: "Equipment", priority: 81, label: "Registrations"
  config.batch_actions = true

  includes :pop, :node, :transport_protocol, :proxy_transport_protocol

  acts_as_export :id, :name, :enabled,
                 [:pop_name, proc { |row| row.pop.try(:name) }],
                 [:node_name, proc { |row| row.node.try(:name) }],
                 [:transport_protocol_name, proc { |row| row.transport_protocol.try(:name) }],
                 :domain,
                 :username,
                 :display_username,
                 :auth_user,
                 :auth_password,
                 :proxy,
                 [:proxy_transport_protocol_name, proc { |row| row.proxy_transport_protocol.try(:name) }],
                 :contact,
                 :expire,
                 :force_expire,
                 :retry_delay,
                 :max_attempts

  acts_as_import resource_class: Importing::Registration
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status

  permit_params :name, :enabled, :pop_id, :node_id, :domain, :username, :display_username,
                :auth_user, :proxy, :contact,
                :auth_password,
                :expire, :force_expire,
                :retry_delay, :max_attempts, :transport_protocol_id, :proxy_transport_protocol_id

  index do
    selectable_column
    id_column
    actions
    column :name
    column :enabled
    column :pop
    column :node
    column :transport_protocol
    column :domain
    column :username
    column :display_username
    column :auth_user
    column :auth_password
    column :proxy
    column :proxy_transport_protocol
    column :contact
    column :expire
    column :force_expire
    column :retry_delay
    column :max_attempts
  end

  filter :id
  filter :name
  filter :enabled, as: :select, collection: [["Yes", true], ["No", false]]
  filter :pop, input_html: {class: 'chosen'}
  filter :node, input_html: {class: 'chosen'}

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :name
      f.input :enabled
      f.input :pop, as: :select,
              include_blank: "Any",
              input_html: {class: 'chosen'}
      f.input :node, as: :select,
              include_blank: "Any",
              input_html: {class: 'chosen'}
      f.input :transport_protocol
      f.input :domain
      f.input :username
      f.input :display_username
      f.input :auth_user
      f.input :auth_password, as: :string
      f.input :proxy
      f.input :proxy_transport_protocol
      f.input :contact
      f.input :expire
      f.input :force_expire
      f.input :retry_delay
      f.input :max_attempts
    end
    f.actions
  end

  show do |s|
    attributes_table do
      row :name
      row :enabled
      row :pop
      row :node
      row :transport_protocol
      row :domain
      row :username
      row :display_username
      row :auth_user
      row :auth_password
      row :proxy
      row :proxy_transport_protocol
      row :contact
      row :expire
      row :force_expire
      row :retry_delay
      row :max_attempts
    end
  end

end