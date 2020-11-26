# frozen_string_literal: true

ActiveAdmin.register Equipment::SipOptionsProber do
  menu parent: 'Equipment', priority: 82, label: 'SIP Options probers'
  config.batch_actions = true

  includes :pop, :node, :transport_protocol, :proxy_transport_protocol, :sip_schema

  acts_as_export :id, :name, :enabled,
                 [:pop_name, proc { |row| row.pop.try(:name) }],
                 [:node_name, proc { |row| row.node.try(:name) }],
                 [:transport_protocol_name, proc { |row| row.transport_protocol.try(:name) }],
                 [:sip_schema_name, proc { |row| row.sip_schema.try(:name) }],
                 :ruri_domain,
                 :ruri_username,
                 :from_uri,
                 :to_uri,
                 :auth_username,
                 :auth_password,
                 :proxy,
                 [:proxy_transport_protocol_name, proc { |row| row.proxy_transport_protocol.try(:name) }],
                 :contact_uri,
                 :interval,
                 :sip_interface_name,
                 :append_headers

  #acts_as_import resource_class: Importing::Registration
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status

  permit_params :name, :enabled, :pop_id, :node_id,
                :ruri_domain, :ruri_username, :from_uri, :to_uri, :contact_uri,
                :auth_username, :proxy, :auth_password,
                :transport_protocol_id, :proxy_transport_protocol_id, :sip_schema_id, :append_headers,
                :inteval, :sip_interface_name

  index do
    selectable_column
    id_column
    actions
    column :name
    column :enabled
    column :pop
    column :node
    column :sip_schema
    column :transport_protocol
    column :ruri_domain
    column :ruri_username
    column :from_uri
    column :to_uri
    column :auth_username
    column :proxy
    column :proxy_transport_protocol
    column :contact_uri
    column :interval
    column :sip_interface_name
    column :append_headers
  end

  filter :id
  filter :name
  filter :enabled, as: :select, collection: [['Yes', true], ['No', false]]
  filter :pop, input_html: { class: 'chosen' }
  filter :node, input_html: { class: 'chosen' }
  filter :sip_schema

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :name
      f.input :enabled
      f.input :pop, as: :select,
              include_blank: 'Any',
              input_html: { class: 'chosen' }
      f.input :node, as: :select,
              include_blank: 'Any',
              input_html: { class: 'chosen' }
      f.input :sip_schema, as: :select, include_blank: false
      f.input :transport_protocol, as: :select, include_blank: false
      f.input :ruri_domain
      f.input :ruri_username
      f.input :from_uri
      f.input :to_uri
      f.input :auth_username
      f.input :auth_password, as: :string
      f.input :proxy
      f.input :proxy_transport_protocol, as: :select, include_blank: false
      f.input :contact_uri
      f.input :interval
      f.input :sip_interface_name
      f.input :append_headers
    end
    f.actions
  end

  show do |_s|
    attributes_table do
      row :name
      row :enabled
      row :pop
      row :node
      row :sip_schema
      row :transport_protocol
      row :ruri_domain
      row :ruri_username
      row :from_uri
      row :to_uri
      row :auth_username
      row :auth_password
      row :proxy
      row :proxy_transport_protocol
      row :contact_uri
      row :interval
      row :sip_interface_name
      row :append_headers
      row :updated_at
      row :created_at
    end
  end
end
