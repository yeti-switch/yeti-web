ActiveAdmin.register Billing::Contact do
  menu parent: "Billing", priority: 3, label: "Contacts"

  acts_as_safe_destroy
  acts_as_audit
  acts_as_clone

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

  filter :id
  filter :contractor, input_html: {class: 'chosen'}
  filter :admin_user, input_html: {class: 'chosen'}
  filter :email
  filter :notes


  show do |s|
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
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :contractor, input_html: {class: 'chosen'}, hint: I18n.t('hints.billing.contact.contractor')
      f.input :admin_user, input_html: {class: 'chosen'}, hint: I18n.t('hints.billing.contact.admin_user')
      f.input :email, hint: I18n.t('hints.billing.contact.email')
      f.input :notes, hint: I18n.t('hints.billing.contact.notes')
    end
    f.actions
  end

end
