ActiveAdmin.register GatewayGroup do

  menu parent: "Equipment", priority: 70

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy

  acts_as_export :id, :name, [:vendor_name, proc { |row| row.vendor.try(:name) }], :prefer_same_pop
  acts_as_import resource_class: Importing::GatewayGroup

  decorate_with GatewayGroupDecorator

  permit_params :vendor_id, :name, :prefer_same_pop

  config.batch_actions = true
  config.scoped_collection_actions_if = -> { true }

  scoped_collection_action :scoped_collection_update,
                           class: 'scoped_collection_action_button ui',
                           form: -> do
                             boolean = [ ['Yes', 't'], ['No', 'f']]
                             {
                               vendor_id: Contractor.vendors.all.map { |v| [v.name, v.id] },
                               prefer_same_pop: boolean
                             }
                           end

  controller do
    def scoped_collection
      super.eager_load(:vendor)
    end
  end

  collection_action :with_contractor do
    @gr = Contractor.find(params[:contractor_id]).gateway_groups
    render text: view_context.options_from_collection_for_select(@gr, :id, :display_name)
  end


  index do
    selectable_column
    id_column
    actions
    column :name
    column :vendor do |c|
      auto_link(c.vendor, c.vendor.decorated_display_name)
    end
    column :prefer_same_pop
  end

  filter :id
  filter :name
  filter :vendor, input_html: {class: 'chosen'}
  filter :prefer_same_pop, as: :select, collection: [["Yes", true], ["No", false]]

  show do |s|
    attributes_table do
      row :id
      row :name
      row :vendor do
        auto_link(s.vendor, s.vendor.decorated_display_name)
      end
      row :prefer_same_pop
    end
    panel("Gateways in group") do
      table_for resource.gateways do |g|
        column :id
        column :name
        column :host
        column :port
      end
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      f.input :name
      f.input :vendor, input_html: {class: 'chosen'}, collection: Contractor.vendors
      f.input :prefer_same_pop
    end
    f.actions
  end


end
