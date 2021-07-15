# frozen_string_literal: true

ActiveAdmin.register DisconnectPolicyCode do
  menu parent: 'Equipment', priority: 81

  config.batch_actions = false

  permit_params :policy_id, :code_id, :stop_hunting, :pass_reason_to_originator,
                :rewrited_code, :rewrited_reason

  controller do
    def scoped_collection
      super.eager_load(:code, :policy)
    end
  end

  index do
    id_column
    actions
    column :policy
    column :code

    column('Stop hunting', sortable: 'stop_hunting') do |r|
      status_tag(r.stop_hunting.to_s, class: r.stop_hunting? ? :ok : :red)
    end
    column('Pass reason to originator', sortable: 'pass_reason_to_originator') do |r|
      status_tag(r.pass_reason_to_originator.to_s, class: r.pass_reason_to_originator? ? :ok : :red)
    end
    column :rewrited_code
    column :rewrited_reason
  end

  filter :id
  filter :policy, input_html: { class: 'chosen' }
  filter :code, input_html: { class: 'chosen' }
  filter :stop_hunting, as: :select, collection: [['Yes', true], ['No', false]]
  filter :pass_reason_to_originator, as: :select, collection: [['Yes', true], ['No', false]]

  show do |_s|
    attributes_table do
      row :id
      row :policy
      row :code
      row('Stop hunting') do |r|
        status_tag(r.stop_hunting.to_s, class: r.stop_hunting? ? :ok : :red)
      end
      row('Pass reason to originator') do |r|
        status_tag(r.pass_reason_to_originator.to_s, class: r.pass_reason_to_originator? ? :ok : :red)
      end
      row :rewrited_code
      row :rewrited_reason
    end
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      f.input :policy, input_html: { class: 'chosen' }
      f.input :code, as: :select,
                     collection: DisconnectCode.where(namespace_id: DisconnectCode::NS_SIP).order(:code),
                     input_html: { class: 'chosen' }
      f.input :stop_hunting
      f.input :pass_reason_to_originator
      f.input :rewrited_code
      f.input :rewrited_reason
    end
    f.actions
  end
end
