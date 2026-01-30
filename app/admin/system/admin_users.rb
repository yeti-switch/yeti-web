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
    column :allowed_ips, :has_allowed_ips
  end

  show do
    attributes_table do
      row :id
      row :username
      row :email
      row :allowed_ips
      row :sign_in_count
      row :current_sign_in_at
      row :last_sign_in_at
      row :current_sign_in_ip
      row :last_sign_in_ip
      row :enabled
      row :roles, &:roles_list
      row :updated_at
      row :created_at
      row :visible_columns, &:pretty_visible_columns
      row :per_page, &:pretty_per_page
      row :saved_filters, &:pretty_saved_filters
    end
  end

  permit_params do
    attrs = %i[stateful_filters allowed_ips]
    attrs_last = { allowed_ips: [] }
    unless AdminUser.ldap?
      attrs.concat %i[username email password password_confirmation]
      attrs_last[:roles] = []
    end
    attrs + [attrs_last]
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
                input_html: { class: 'tom-select', multiple: true }
      end
      f.input :stateful_filters
      f.input :allowed_ips, as: :array_of_strings
    end
    f.actions
  end
  #  end

  unless AdminUser.ldap?
    # link to change own password
    action_item :change_password, only: :show do
      if authorized?(:change_password, resource.model)
        link_to 'Change Password', url_for(action: :change_password)
      end
    end

    # form to change own password
    collection_action :change_password, method: :get do
      authorize!(:change_password, current_admin_user)
      @form = AdminUserPasswordForm.new(current_admin_user)
      # renders app/views/admin_users/change_password.html.erb
    end

    # action to change own password
    collection_action :submit_password, method: :post do
      # param_key = active_admin_config.param_key.to_sym
      param_key = AdminUserPasswordForm.model_name.param_key.to_sym
      permitted_params = params.require(param_key).permit(:password, :password_confirmation)
      @form = AdminUserPasswordForm.new(current_admin_user, permitted_params)
      if @form.save
        flash[:notice] = 'Password was successfully changed'
        redirect_to admin_user_path(current_admin_user.id)
      else
        render :change_password
      end
    end
  end
end
