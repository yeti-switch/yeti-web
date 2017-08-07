ActiveAdmin.register Equipment::Radius::AuthProfile do
  menu parent: "Equipment", priority: 110, label: 'RADIUS Auth profile'
  config.batch_actions = true

  acts_as_audit
  acts_as_clone :avps
  acts_as_safe_destroy

  acts_as_export :id, :name

  permit_params :name, :server, :port, :secret, :reject_on_error, :timeout, :attempts,
                avps_attributes: [
                    :id, :type_id, :name, :value, :format, :is_vsa, :vsa_vendor_id, :vsa_vendor_type, :_destroy
                ]

  includes :avps

  batch_action :set_reject_on_error, confirm: "Are you sure?" do |selection|
    active_admin_config.resource_class.find(selection).each do |resource|
      resource.set_reject_on_error
    end
    redirect_to collection_path, notice: "#{active_admin_config.resource_label.pluralize} are updated!"
  end

  batch_action :unset_reject_on_error, confirm: "Are you sure?" do |selection|
    active_admin_config.resource_class.find(selection).each do |resource|
      resource.unset_reject_on_error
    end
    redirect_to collection_path, notice: "#{active_admin_config.resource_label.pluralize} are updated!"
  end

  index do
    selectable_column
    id_column
    actions
    column :name
    column :server
    column :port
    column :reject_on_error
    column :timeout
    column :attempts
  end

  filter :id
  filter :name
  filter :reject_on_error, as: :select, collection: [ ["Yes", true], ["No", false]]

  form do |f|
    f.semantic_errors *f.object.errors.keys.uniq
    f.inputs form_title do
      f.input :name, hint: I18n.t('hints.equipment.radius_auth_profile.name')
      f.input :server, hint: I18n.t('hints.equipment.radius_auth_profile.name')
      f.input :port, hint: I18n.t('hints.equipment.radius_auth_profile.name')
      f.input :secret, hint: I18n.t('hints.equipment.radius_auth_profile.name')
      f.input :reject_on_error
      f.input :timeout, hint: "Request timeout in ms. Allowed values #{Equipment::Radius::AuthProfile::TIMEOUT_MIN}..#{Equipment::Radius::AuthProfile::TIMEOUT_MAX}"
      f.input :attempts, hint: "Max request attempts. Allowed values #{Equipment::Radius::AuthProfile::ATTEMPTS_MIN}..#{Equipment::Radius::AuthProfile::ATTEMPTS_MAX}"
    end

    f.inputs "Attributes" do
      f.has_many :avps do |t|
        t.input :type_id, hint: I18n.t('hints.equipment.radius_auth_profile.avps.type_id')
        t.input :name, hint: I18n.t('hints.equipment.radius_auth_profile.avps.name')
        t.input :is_vsa
        t.input :vsa_vendor_id, hint: I18n.t('hints.equipment.radius_auth_profile.avps.vsa_vendor_id')
        t.input :vsa_vendor_type, hint: I18n.t('hints.equipment.radius_auth_profile.avps.vsa_vendor_type')
        t.input :value, hint: I18n.t('hints.equipment.radius_auth_profile.avps.value')
        t.input :format, as: :select, collection: Equipment::Radius::AuthProfileAttribute::FORMATS,
                hint: I18n.t('hints.equipment.radius_auth_profile.avps.format')
        t.input :_destroy, as: :boolean, required: false, label: 'Remove' unless  t.object.new_record?
      end
    end
    f.actions
  end

  sidebar :allowed_variables, only: [:new, :edit] do
    ul do
      Equipment::Radius::AuthProfileAttribute.variables.each do |x|
        li do
          strong do
            "$#{x['varname']}$"
          end
        end
      end
    end
  end


  show do |s|
    attributes_table do
      row :id
      row :name
      row :server
      row :port
      row :secret
      row :reject_on_error
      row :timeout
      row :attempts
    end

    panel "Attributes" do
      table_for s.avps.order("id") do
        column :type_id
        column :name
        column :is_vsa
        column :vsa_vendor_id
        column :vsa_vendor_type
        column :value
        column :format
      end
    end
  end


end
