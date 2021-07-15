# frozen_string_literal: true

ActiveAdmin.register Equipment::Radius::AccountingProfile do
  menu parent: %w[Equipment RADIUS], priority: 120, label: 'RADIUS Accounting profile'
  config.batch_actions = false

  acts_as_audit
  acts_as_clone :stop_avps, :start_avps, :interim_avps
  acts_as_safe_destroy

  acts_as_export :id, :name

  permit_params :name, :server, :port, :secret, :reject_on_error, :timeout, :attempts,
                :enable_start_accounting, :enable_interim_accounting, :interim_accounting_interval,
                :enable_stop_accounting,
                stop_avps_attributes: %i[
                  id type_id name value format is_vsa vsa_vendor_id vsa_vendor_type _destroy
                ],
                start_avps_attributes: %i[
                  id type_id name value format is_vsa vsa_vendor_id vsa_vendor_type _destroy
                ],
                interim_avps_attributes: %i[
                  id type_id name value format is_vsa vsa_vendor_id vsa_vendor_type _destroy
                ]

  includes :stop_avps, :start_avps, :interim_avps

  index do
    selectable_column
    id_column
    actions
    column :name
    column :server
    column :port
    column :timeout
    column :attempts
    column :enable_start_accounting
    column :enable_interim_accounting
    column :interim_accounting_interval
    column :enable_stop_accounting
  end

  filter :id
  filter :name

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :name
      f.input :server
      f.input :port
      f.input :secret
      f.input :timeout, hint: "Request timeout in ms. Allowed values #{Equipment::Radius::AccountingProfile::TIMEOUT_MIN}..#{Equipment::Radius::AccountingProfile::TIMEOUT_MAX}"
      f.input :attempts, hint: "Max request attempts. Allowed values #{Equipment::Radius::AccountingProfile::ATTEMPTS_MIN}..#{Equipment::Radius::AccountingProfile::ATTEMPTS_MAX}"
      f.input :enable_start_accounting
      f.input :enable_interim_accounting
      f.input :interim_accounting_interval
      f.input :enable_stop_accounting
    end
    f.inputs 'Start packet attributes' do
      f.has_many :start_avps do |t|
        t.input :type_id, hint: 'Attribute type, see rfc2865'
        t.input :name, hint: 'Informational only'
        t.input :is_vsa
        t.input :vsa_vendor_id
        t.input :vsa_vendor_type
        t.input :value
        t.input :format, as: :select, collection: Equipment::Radius::Attribute::FORMATS
        t.input :_destroy, as: :boolean, required: false, label: 'Remove' unless t.object.new_record?
      end
    end

    f.inputs 'Interim packet attributes' do
      f.has_many :interim_avps do |t|
        t.input :type_id, hint: 'Attribute type, see rfc2865'
        t.input :name, hint: 'Informational only'
        t.input :is_vsa
        t.input :vsa_vendor_id
        t.input :vsa_vendor_type
        t.input :value
        t.input :format, as: :select, collection: Equipment::Radius::Attribute::FORMATS
        t.input :_destroy, as: :boolean, required: false, label: 'Remove' unless t.object.new_record?
      end
    end

    f.inputs 'Stop packet attributes' do
      f.has_many :stop_avps do |t|
        t.input :type_id, hint: 'Attribute type, see rfc2865'
        t.input :name, hint: 'Informational only'
        t.input :is_vsa
        t.input :vsa_vendor_id
        t.input :vsa_vendor_type
        t.input :value
        t.input :format, as: :select, collection: Equipment::Radius::Attribute::FORMATS
        t.input :_destroy, as: :boolean, required: false, label: 'Remove' unless t.object.new_record?
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
      row :timeout
      row :attempts
      row :enable_start_accounting
      row :enable_interim_accounting
      row :interim_accounting_interval
      row :enable_stop_accounting
    end
    panel 'START packet attributes' do
      table_for s.start_avps.order('id') do
        column :type_id
        column :name
        column :is_vsa
        column :vsa_vendor_id
        column :vsa_vendor_type
        column :value
        column :format
      end
    end

    panel 'INTERIM packet attributes' do
      table_for s.interim_avps.order('id') do
        column :type_id
        column :name
        column :is_vsa
        column :vsa_vendor_id
        column :vsa_vendor_type
        column :value
        column :format
      end
    end

    panel 'STOP packet attributes' do
      table_for s.stop_avps.order('id') do
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
