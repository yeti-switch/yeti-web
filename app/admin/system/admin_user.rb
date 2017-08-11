ActiveAdmin.register AdminUser do

  menu parent: "System",  priority: 2

  controller do
    def update_resource(object, attributes)
      if object.root?
        object.update(*attributes)
      else
        object.customized_update(*attributes)
      end

    end
  end

  acts_as_status
  acts_as_export
  action_list = [:index, :show, :edit, :update]
  action_list = action_list + [:create, :new ] unless AdminUser.ldap?
  actions *action_list

  permit_params :username, :email,
                :password, :password_confirmation, :ssh_key, :stateful_filters
  includes :billing_contact

  index do
    id_column
    actions
    column :username  do |user|
      text = "".html_safe
      text <<  user.username
      text << " "
      text << fa_icon(:bolt)  if user.root?
      text
    end

    column :enabled
    column :current_sign_in_at
    column :email
    column :last_sign_in_at           
    column :sign_in_count
    column :ssh_key  do |row|
      status_tag(row.ssh_key.present?.to_s, class: row.ssh_key.present? ? :ok : nil)
    end
  end

  filter :billing_contact_email, as: :string
  filter :username

 show do |user|
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
       row :group do
         user.root? ? 'ROOT' : 'ADMIN'
       end
       row :updated_at
       row :created_at
       row :ssh_key
       row :visible_columns do
         content_tag :pre, JSON.pretty_generate(user.visible_columns), style: 'white-space: pre-wrap; word-wrap: break-word;'
       end
       row :per_page do
         content_tag :pre, JSON.pretty_generate(user.per_page), style: 'white-space: pre-wrap; word-wrap: break-word;'
       end
       row :saved_filters do
         content_tag :pre, JSON.pretty_generate(user.saved_filters), style: 'white-space: pre-wrap; word-wrap: break-word;'
       end
     end

 end

# unless AdminUser.ldap?
  form do |f|
    f.semantic_errors *f.object.errors.keys.uniq
    f.inputs "Admin Details" do
      unless AdminUser.ldap?
        f.input :email
        f.input :username
        f.input :password
        f.input :password_confirmation
      end
      f.input :ssh_key
      f.input :stateful_filters
    end
    f.actions
  end
#  end

end                                   
