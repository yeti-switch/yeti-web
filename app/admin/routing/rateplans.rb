# frozen_string_literal: true

ActiveAdmin.register Routing::Rateplan do
  menu parent: 'Routing', label: 'Rateplans', priority: 40

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  acts_as_export :id, :name,
                 [:profit_control_mode_name, proc { |row| row.profit_control_mode.name }]

  acts_as_import resource_class: Importing::Rateplan

  permit_params :name, :profit_control_mode_id, rate_group_ids: [], send_quality_alarms_to: []

  includes :profit_control_mode, :rate_groups, :routing_rateplans_rate_groups

  index do
    selectable_column
    id_column
    actions
    column :name
    column 'Rate Groups' do |r|
      raw(r.rate_groups.map { |rg| link_to rg.name, destinations_path(q: { rate_group_id_eq: rg.id }) }.sort.join(', '))
    end
    column :profit_control_mode
    column :send_quality_alarms_to do |r|
      r.contacts.map(&:email).sort.join(', ')
    end
    column :uuid
    column :external_id
  end

  filter :id
  filter :uuid_equals, label: 'UUID'
  filter :name
  filter :external_id
  filter :profit_control_mode, input_html: { class: 'chosen' }, collection: proc { Routing::RateProfitControlMode.pluck(:name, :id) }

  form do |f|
    f.semantic_errors(*f.object.errors.keys)
    f.inputs do
      f.input :name
      f.input :rate_groups, input_html: { class: 'chosen-sortable', multiple: true }
      f.input :profit_control_mode
      f.input :send_quality_alarms_to, as: :select, input_html: { class: 'chosen-sortable', multiple: true }, collection: Billing::Contact.collection
    end
    f.actions
  end

  show do |s|
    attributes_table do
      row :id
      row :uuid
      row :name
      row 'Rate Groups' do |r|
        raw(r.rate_groups.map { |rg| link_to rg.name, destinations_path(q: { rate_group_id_eq: rg.id }) }.sort.join(', '))
      end
      row :profit_control_mode
      row :send_quality_alarms_to do
        s.contacts.map(&:email).sort.join(', ')
      end
      row :external_id
    end
  end

  sidebar :links, only: %i[show edit] do
    ul do
      li do
        link_to 'Destinations', destinations_path(q: { rateplan_id_eq: params[:id] })
      end
      li do
        link_to 'Customer Auths', customers_auths_path(q: { rateplan_id_eq: params[:id] })
      end
      li do
        link_to 'CDR list', cdrs_path(q: { rateplan_id_eq: params[:id] })
      end
    end
  end
end
