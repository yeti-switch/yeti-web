# frozen_string_literal: true

ActiveAdmin.register System::LuaScript do
  menu parent: 'System', label: 'Lua Scripts', priority: 10

  acts_as_clone
  acts_as_audit

  permit_params :name, :source

  filter :id
  filter :name

  index do
    selectable_column
    id_column
    actions
    column :name
    column :created_at
    column :updated_at
  end

  show do |_s|
    attributes_table do
      row :id
      row :name
      row :source do |row|
        pre code row.source
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name
      f.input :source, as: :text
    end
    f.actions
  end
end
