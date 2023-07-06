# frozen_string_literal: true

ActiveAdmin.register Equipment::StirShaken::SigningCertificate do
  menu parent: %w[Equipment STIR/SHAKEN], label: 'Signing certificates', priority: 30
  config.batch_actions = false

  acts_as_clone

  permit_params :id, :name, :certificate, :key, :url

  filter :id
  filter :name

  index do
    id_column
    actions
    column :name
    column :certificate do |c|
      pre code c.certificate
    end
    column :url
    column :updated_at
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :certificate, as: :text
      f.input :key, as: :text
      f.input :url
    end
    f.actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :certificate do |row|
        pre code row.certificate
      end
      row :key do |row|
        pre code row.key
      end
      row :url
      row :updated_at
    end
    active_admin_comments
  end
end
