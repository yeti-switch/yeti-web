# frozen_string_literal: true

ActiveAdmin.register Equipment::StirShaken::SigningCertificate do
  menu parent: %w[Equipment STIR/SHAKEN], label: 'Signing certificates', priority: 30
  config.batch_actions = false

  acts_as_audit
  acts_as_clone

  permit_params :id, :name, :certificate, :key, :x5u

  filter :id
  filter :name

  index do
    id_column
    actions
    column :name
    column :certificate do |c|
      pre code c.certificate
    end
    column 'Certificate Details' do |c|
      pre code c.certificate_details
    end
    column :x5u
    column :updated_at
  end

  form do |f|
    f.inputs do
      f.input :name
      f.input :certificate, as: :text
      f.input :key, as: :text
      f.input :x5u
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
      row 'Certificate Details' do |row|
        pre code row.certificate_details
      end
      row :key do |row|
        pre code row.key
      end
      row :x5u
      row :updated_at
    end
    active_admin_comments
  end
end
