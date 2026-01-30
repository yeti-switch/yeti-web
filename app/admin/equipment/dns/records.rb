# frozen_string_literal: true

ActiveAdmin.register Equipment::Dns::Record do
  menu parent: %w[Equipment DNS], label: 'DNS Records', priority: 60
  config.batch_actions = false

  acts_as_audit
  acts_as_clone

  acts_as_export :id, :name,
                 [:zone_name, proc { |row| row.zone.try(:name) }],
                 :record_type, :content,
                 [:contractor_name, proc { |row| row.contractor.try(:name) }]

  permit_params :zone_id, :name, :record_type, :content, :contractor_id

  includes :zone, :contractor

  filter :id
  filter :name
  filter :content
  filter :zone, input_html: { class: 'tom-select' }
  contractor_filter :contractor_id_eq

  index do
    id_column
    actions
    column :name
    column :zone
    column :record_type
    column :content
    column :contractor
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :zone, input_html: { class: 'tom-select' }
      f.input :record_type,
              as: :select,
              include_blank: false,
              collection: Equipment::Dns::Record::RECORD_TYPES.invert,
              input_html: { class: 'tom-select' }
      f.input :content
      f.contractor_input :contractor_id
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :zone
      row :record_type
      row :content
      row :contractor
    end
    active_admin_comments
  end
end
