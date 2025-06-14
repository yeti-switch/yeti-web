# frozen_string_literal: true

ActiveAdmin.register Equipment::StirShaken::TrustedCertificate do
  menu parent: %w[Equipment STIR/SHAKEN], label: 'Trusted certificates', priority: 20
  config.batch_actions = false

  acts_as_audit
  acts_as_clone

  permit_params :id, :name, :certificate

  filter :id
  filter :name

  index do
    id_column
    actions
    column :name
    column :certificate do |c|
      pre code c.certificate
    end
    column :updated_at
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :certificate, as: :text
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
      row :updated_at
    end
    active_admin_comments
  end
end
