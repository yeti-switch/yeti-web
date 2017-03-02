ActiveAdmin.register Routing::RoutingPlan do
  menu parent: "Routing", label: "Routing plans", priority: 52

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy


  acts_as_batch_changeable [:enabled, :use_lnp, :rate_delta_max]

  permit_params :name, :sorting_id, :use_lnp, :rate_delta_max, {routing_group_ids: []}

  filter :id
  filter :name
  filter :sorting
  filter :use_lnp, as: :select, collection: [["Yes", true], ["No", false]]
  filter :customers_auths_account_id_eq, as: :select, label: "Assigned to account", collection: -> { Account.customers_accounts }


  index do
    selectable_column
    id_column
    actions
    column :name
    column :sorting, sortable: 'sortings.name'
    column "Use LNP", :use_lnp
    column :rate_delta_max
    column "Routing groups" do |r|
      raw(r.routing_groups.map { |rg| link_to rg.name, dialpeers_path(q: {routing_group_id_eq: rg.id}) }.sort.join(', '))
    end

  end

  show do |s|
    # tabs do
    #   tab "Details" do
    attributes_table do
      row :id
      row :name
      row :sorting
      row :use_lnp
      row :rate_delta_max
      row "Routing groups" do |r|
        raw(r.routing_groups.map { |rg| link_to rg.name, dialpeers_path(q: {routing_group_id_eq: rg.id}) }.sort.join(', '))
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors # show errors on :base by default
    f.inputs form_title do
      f.input :name
      f.input :sorting
      f.input :use_lnp
      f.input :rate_delta_max
      f.input :routing_groups, input_html: {class: 'chosen-sortable', multiple: true}
    end
    f.actions
  end


  controller do
    def scoped_collection
      super.eager_load(:sorting)
    end
  end


  sidebar :links, only: [:show, :edit] do

    ul do
      li do
        link_to "Customer Auths", customers_auths_path(q: {routing_plan_id_eq: params[:id]})
      end
      li do
        link_to "CDR list", cdrs_path(q: {routing_plan_id_eq: params[:id]})
      end
      li do
        link_to "Static routes(#{resource.static_routes.count})" ,static_routes_path(q: {routing_plan_id_eq: params[:id] })
      end  if resource.use_static_routes?



    end
  end

end
