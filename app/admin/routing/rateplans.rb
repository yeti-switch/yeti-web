ActiveAdmin.register Rateplan do

  menu parent: 'Routing', priority: 40

  acts_as_audit
  acts_as_clone_with_helper helper: Routing::RateplanDuplicator, name: "Copy with destinations"
  acts_as_safe_destroy

  acts_as_export :id, :name
  acts_as_import resource_class: Importing::Rateplan

  permit_params :name, :profit_control_mode_id, send_quality_alarms_to: []

  controller do
    def scoped_collection
      super.eager_load(:profit_control_mode)
    end
  end

  index do
    selectable_column
    id_column
    actions
    column :name
    column :profit_control_mode
    column :send_quality_alarms_to do |r|
      r.contacts.map { |p| p.email }.sort.join(", ")
    end
    column :uuid
  end



  filter :id
  filter :uuid_equals, label: 'UUID'
  filter :name
  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs do
      f.input :name
      f.input :profit_control_mode
      f.input :send_quality_alarms_to, as: :select, input_html: {class: 'chosen-sortable', multiple: true}, collection: Billing::Contact.collection
    end
    f.actions
  end

  show do |s|
    attributes_table do
      row :id
      row :uuid
      row :name
      row :profit_control_mode
      row :send_quality_alarms_to do
        s.contacts.map { |p| p.email }.sort.join(", ")
      end
    end

  end

  sidebar :links, only: [:show, :edit] do
    ul do
      li do
        link_to 'Destinations', destinations_path(q: {rateplan_id_eq: params[:id]})
      end
      li do
        link_to 'Customer Auths', customers_auths_path(q: {rateplan_id_eq: params[:id]})
      end
      li do
        link_to 'CDR list', cdrs_path(q: {rateplan_id_eq: params[:id]})
      end
    end
  end

end
