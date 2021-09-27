# frozen_string_literal: true

ActiveAdmin.register AdminUser do
  menu parent: 'System', priority: 2
  decorate_with AdminUserDecorator

  acts_as_status
  acts_as_export
  acts_as_safe_destroy
  action_list = %i[index show edit update destroy]
  action_list += %i[create new] unless AdminUser.ldap?
  actions(*action_list)

  filter :billing_contact_email, as: :string
  filter :username

  controller do
    def scoped_collection
      super.preload(:billing_contact)
    end
  end

  index do
    selectable_column
    id_column
    actions
    column :username
    column :enabled
    column :current_sign_in_at
    column :email
    column :last_sign_in_at
    column :sign_in_count
    column :ssh_key, :ssh_key_tag
  end

  show do
    attributes_table do
      row :id
      row :username
      row :email
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :enabled
      row :roles, &:roles_list
      row :updated_at
      row :created_at
      row :ssh_key
      row :visible_columns, &:pretty_visible_columns
      row :per_page, &:pretty_per_page
      row :saved_filters, &:pretty_saved_filters
    end
  end

  permit_params do
    attrs = %i[ssh_key stateful_filters]
    unless AdminUser.ldap?
      attrs.concat %i[username email password password_confirmation]
      attrs.push(roles: [])
    end
    attrs
  end

  # unless AdminUser.ldap?
  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs 'Admin Details' do
      unless AdminUser.ldap?
        f.input :email
        f.input :username
        f.input :password, input_html: { autocomplete: 'new-password' }
        f.input :password_confirmation, input_html: { autocomplete: 'new-password' }
        f.input :roles,
                as: :select,
                collection: AdminUser.available_roles,
                input_html: { multiple: true }
      end
      f.input :ssh_key
      f.input :stateful_filters
    end
    f.actions
  end
  #  end
end
