# frozen_string_literal: true

ActiveAdmin.register Billing::Contact do
  includes :contractor, :admin_user
  menu parent: 'Billing', priority: 3, label: 'Contacts'

  acts_as_safe_destroy
  acts_as_audit
  acts_as_clone
  acts_as_async_destroy('Billing::Contact')
  acts_as_async_update BatchUpdateForm::Contact

  acts_as_delayed_job_lock

  acts_as_export :id,
                 [:contractor_name, proc { |row| row.contractor.try(:name) }],
                 [:admin_user_name, proc { |row| row.admin_user.try(:username) }],
                 :name,
                 :notes,
                 :created_at,
                 :updated_at

  permit_params :contractor_id, :admin_user_id, :email, :notes, :created_at, :updated_at

  index do
    selectable_column
    actions
    id_column
    column :contractor
    column :admin_user
    column :email
    column :created_at
    column :updated_at
    column :notes
  end

  filters do
    filter :id
    filter :contractor_id_eq, label: 'Contractor' do
      as :tom_select
      ajax resource: 'Contractor'
      ajax_params q: { s: :name }
    end
    filter :admin_user, as: :tom_select
    filter :email
    filter :notes
  end

  show do |_s|
    attributes_table do
      row :id
      row :contractor
      row :admin_user
      row :email
      row :notes
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :contractor_id, as: :tom_select, ajax: { resource: 'Contractor' }
      f.input :admin_user, as: :tom_select
      f.input :email
      f.input :notes
    end
    f.actions
  end
end
