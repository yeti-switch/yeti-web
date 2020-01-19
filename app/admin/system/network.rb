# frozen_string_literal: true

ActiveAdmin.register System::Network do
  actions :all
  menu parent: 'System', label: 'Networks', priority: 130
  config.batch_actions = false
  permit_params :name, :type_id

  filter :id
  filter :uuid_equals, label: 'UUID'
  filter :name
  filter :type_id_eq,
         label: 'Type',
         as: :select,
         input_html: { class: :chosen },
         collection: proc { System::NetworkType.collection }

  index do
    id_column
    column :name
    column :type, :network_type
    column :uuid
  end

  show do
    attributes_table do
      row :id
      row :name
      row :type, &:network_type
      row :uuid
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :name
      f.input :type_id,
              as: :select,
              input_html: { class: :chosen },
              collection: System::NetworkType.collection
    end
    f.actions
  end
end
