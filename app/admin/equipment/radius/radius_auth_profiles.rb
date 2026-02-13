# frozen_string_literal: true

ActiveAdmin.register Equipment::Radius::AuthProfile do
  menu parent: %w[Equipment RADIUS], priority: 110, label: 'RADIUS Auth profile'
  config.batch_actions = true

  acts_as_audit
  acts_as_clone duplicates: [:avps]
  acts_as_safe_destroy

  acts_as_export :id, :name

  permit_params :name, :server, :port, :secret, :reject_on_error, :timeout, :attempts,
                avps_attributes: %i[
                  id type_id name value format is_vsa vsa_vendor_id vsa_vendor_type _destroy
                ]

  includes :avps

  batch_action :set_reject_on_error, confirm: 'Are you sure?', if: proc { authorized?(:batch_update) } do |selection|
    active_admin_config.resource_class.find(selection).each(&:set_reject_on_error)
    redirect_to collection_path, notice: "#{active_admin_config.resource_label.pluralize} are updated!"
  end

  batch_action :unset_reject_on_error, confirm: 'Are you sure?', if: proc { authorized?(:batch_update) } do |selection|
    active_admin_config.resource_class.find(selection).each(&:unset_reject_on_error)
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
  boolean_filter :reject_on_error

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :server
      f.input :port
      f.input :secret
      f.input :reject_on_error
      f.input :timeout, hint: "Request timeout in ms. Allowed values #{Equipment::Radius::AuthProfile::TIMEOUT_MIN}..#{Equipment::Radius::AuthProfile::TIMEOUT_MAX}"
      f.input :attempts, hint: "Max request attempts. Allowed values #{Equipment::Radius::AuthProfile::ATTEMPTS_MIN}..#{Equipment::Radius::AuthProfile::ATTEMPTS_MAX}"
    end

    f.inputs 'Attributes' do
      f.has_many :avps do |t|
        t.input :type_id, hint: 'Attribute type, see rfc2865'
        t.input :name, hint: 'Informational only'
        t.input :is_vsa
        t.input :vsa_vendor_id
        t.input :vsa_vendor_type
        t.input :value
        t.input :format, as: :select, collection: Equipment::Radius::AuthProfileAttribute::FORMATS, input_html: { class: 'tom-select' }
        t.input :_destroy, as: :boolean, required: false, label: 'Remove' unless  t.object.new_record?
      end
    end
    f.actions
  end

  sidebar :allowed_variables, only: %i[new edit] do
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

    panel 'Attributes' do
      table_for s.avps.order('id') do
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
