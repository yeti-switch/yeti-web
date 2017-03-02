ActiveAdmin.register DisconnectCode do
  menu parent: "System", priority: 20

  config.batch_actions = false
  actions :index, :show, :edit, :update

  controller do
    def scoped_collection
      super.eager_load(:namespace)
    end  
  end

  permit_params :stop_hunting, :pass_reason_to_originator, :rewrited_code, :rewrited_reason,:store_cdr,:silently_drop

  index do
    id_column
    actions
    column :namespace
    column :code
    column :reason

    column("Success", sortable: 'success') do |r|
      status_tag(r.success.to_s, r.success.to_s, class: r.success? ? :ok : :red)
    end

    column("Success when non-zero length", sortable: 'successnozerolen') do |r|
      status_tag(r.successnozerolen.to_s, r.successnozerolen.to_s, class: r.successnozerolen? ? :ok : :red)
    end

    column("Stop hunting", sortable: 'stop_hunting') do |r|
      status_tag(r.stop_hunting.to_s, r.stop_hunting.to_s, class: r.stop_hunting? ? :ok : :red)
    end
    column("Pass reason to originator", sortable: 'pass_reason_to_originator') do |r|
      status_tag(r.pass_reason_to_originator.to_s, r.pass_reason_to_originator.to_s, class: r.pass_reason_to_originator? ? :ok : :red)
    end
    column :rewrited_code
    column :rewrited_reason
    column("Store CDR", sortable: 'store_cdr') do |r|
      status_tag(r.store_cdr.to_s, r.store_cdr.to_s, class: r.store_cdr? ? :ok : :red)
    end
    column("Silenly drop", sortable: 'silently_drop') do |r|
      status_tag(r.silently_drop.to_s, r.silently_drop.to_s, class: r.silently_drop? ? :ok : :red)
    end
  end

  filter :id
  filter :code
  filter :namespace
  filter :success, as: :select, collection: [["Yes", true], ["No", false]]
  filter :stop_hunting, as: :select, collection: [["Yes", true], ["No", false]]
  filter :store_cdr, as: :select, collection: [["Yes", true], ["No", false]]
  filter :silently_drop, as: :select, collection: [["Yes", true], ["No", false]]
  show do |s|
    attributes_table do
      row :id
      row :namespace
      row :code
      row :reason
      row("Success") do |r|
        status_tag(r.success.to_s, r.success.to_s, class: r.success? ? :ok : :red)
      end
      row("Success when non-zero length") do |r|
        status_tag(r.successnozerolen.to_s, r.successnozerolen.to_s, class: r.successnozerolen? ? :ok : :red)
      end

      row("Stop hunting") do |r|
        status_tag(r.stop_hunting.to_s, r.stop_hunting.to_s, class: r.stop_hunting? ? :ok : :red)
      end
      row("Pass reason to originator") do |r|
        status_tag(r.pass_reason_to_originator.to_s, r.pass_reason_to_originator.to_s, class: r.pass_reason_to_originator? ? :ok : :red)
      end
      row :rewrited_code
      row :rewrited_reason
      row("Store CDR") do |r|
        status_tag(r.store_cdr.to_s, r.store_cdr.to_s, class: r.store_cdr? ? :ok : :red)
      end
      row("Silenly drop") do |r|
        status_tag(r.silently_drop.to_s, r.silently_drop.to_s, class: r.silently_drop? ? :ok : :red)
      end

    end
  end
  ##### clean this #####
  form do |f|
    f.semantic_errors # show errors on :base by default
    f.inputs form_title do
      if resource.namespace_id==DisconnectCode::NS_TM ## TM
        f.input :namespace, input_html: {readonly: true, disabled: true}
        f.input :code, input_html: {readonly: true, disabled: true}
        f.input :reason, input_html: {readonly: true, disabled: true}
        f.input :success, input_html: {readonly: true, disabled: true}
        f.input :successnozerolen, input_html: {readonly: true, disabled: true}
        f.input :stop_hunting, input_html: {readonly: true, disabled: true}
        f.input :pass_reason_to_originator
        f.input :rewrited_code
        f.input :rewrited_reason
        f.input :store_cdr
        f.input :silently_drop
      else
        f.input :namespace, input_html: {readonly: true, disabled: true}
        f.input :code, input_html: {readonly: true, disabled: true}
        f.input :reason, input_html: {readonly: true, disabled: true}
        f.input :success, input_html: {readonly: true, disabled: true}
        f.input :successnozerolen, input_html: {readonly: true, disabled: true}
        f.input :stop_hunting
        f.input :pass_reason_to_originator
        f.input :rewrited_code
        f.input :rewrited_reason
        f.input :store_cdr, input_html: {readonly: true, disabled: true}
        f.input :silently_drop, input_html: {readonly: true, disabled: true}
      end
    end
    f.actions
  end

end
