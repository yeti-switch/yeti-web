# frozen_string_literal: true

ActiveAdmin.register Equipment::StirShaken::RcdProfile do
  menu parent: %w[Equipment STIR/SHAKEN], label: 'Rich Call Data Profiles', priority: 30
  config.batch_actions = false

  acts_as_audit
  acts_as_clone

  permit_params :id, :mode_id, :nam, :apn, :icn, :jcd_json, :jcl

  filter :id
  filter :external_id
  filter :mode_id_eq, label: 'Mode', as: :select, collection: Equipment::StirShaken::RcdProfile::MODES.invert
  filter :nam
  filter :icn
  filter :jcl

  index do
    id_column
    actions
    column :external_id
    column :mode, &:mode_name
    column :nam
    column :apn
    column :icn
    column :jcd
    column :jcl
    column :created_at
    column :updated_at
  end

  form do |f|
    f.inputs do
      f.input :mode_id,
              as: :select,
              include_blank: false,
              collection: Equipment::StirShaken::RcdProfile::MODES.invert
      f.input :nam
      f.input :apn
      f.input :icn
      f.input :jcd_json, label: 'jcd', as: :text
      f.input :jcl
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :mode, &:mode_name
      row :nam
      row :apn
      row :icn
      row :jcd do
        pre code JSON.pretty_generate(resource.jcd)
      end
      row :jcl
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end
end
