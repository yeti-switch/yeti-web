# frozen_string_literal: true

ActiveAdmin.register Equipment::SipOptionsProber do
  menu parent: 'Equipment', priority: 82, label: 'SIP Options probers'
  config.batch_actions = true

  includes :pop, :node, :transport_protocol

  acts_as_audit
  acts_as_export :id, :name, :enabled,
                 [:pop_name, proc { |row| row.pop.try(:name) }],
                 [:node_name, proc { |row| row.node.try(:name) }],
                 [:transport_protocol_name, proc { |row| row.transport_protocol.try(:name) }],
                 :sip_schema_name,
                 :ruri_domain,
                 :ruri_username,
                 :from_uri,
                 :to_uri,
                 :auth_username,
                 :route_set,
                 :contact_uri,
                 :interval,
                 :sip_interface_name,
                 :append_headers

  # acts_as_import resource_class: Importing::Registration
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status

  permit_params :name, :enabled, :pop_id, :node_id,
                :ruri_domain, :ruri_username, :from_uri, :to_uri, :contact_uri,
                :auth_username, :route_set, :auth_password,
                :transport_protocol_id, :sip_schema_id, :append_headers,
                :interval, :sip_interface_name

  index do
    selectable_column
    id_column
    actions
    column :name
    column :enabled
    column :pop
    column :node
    column :sip_schema_id, &:sip_schema_name
    column :transport_protocol
    column :ruri_domain
    column :ruri_username
    column :from_uri
    column :to_uri
    column :auth_username
    column :route_set
    column :contact_uri
    column :interval
    column :sip_interface_name
    column :append_headers
    column :external_id
  end

  filter :id
  filter :name
  boolean_filter :enabled
  filter :pop, input_html: { class: 'tom-select' }
  filter :node, input_html: { class: 'tom-select' }
  filter :sip_schema_id, as: :select, collection: proc { Equipment::SipOptionsProber::SIP_SCHEMAS.invert }, input_html: { class: 'tom-select' }
  filter :external_id

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :enabled
      f.input :pop, as: :select,
                    include_blank: 'Any',
                    input_html: { class: 'tom-select' }
      f.input :node, as: :select,
                     include_blank: 'Any',
                     input_html: { class: 'tom-select' }
      f.input :sip_schema_id, as: :select, include_blank: false, collection: Equipment::SipOptionsProber::SIP_SCHEMAS.invert, input_html: { class: 'tom-select' }
      f.input :transport_protocol, as: :select, include_blank: false, input_html: { class: 'tom-select' }
      f.input :ruri_domain
      f.input :ruri_username
      f.input :from_uri
      f.input :to_uri
      f.input :auth_username
      if authorized?(:allow_auth_credentials)
        f.input :auth_password, as: :string
      end
      f.input :route_set, as: :newline_array_of_headers
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
      row :sip_schema_id, &:sip_schema_name
      row :transport_protocol
      row :ruri_domain
      row :ruri_username
      row :from_uri
      row :to_uri
      row :auth_username
      if authorized?(:allow_auth_credentials)
        row :auth_password
      end
      row :route_set
      row :contact_uri
      row :interval
      row :sip_interface_name
      row :append_headers
      row :updated_at
      row :created_at
      row :external_id
    end
  end
end
