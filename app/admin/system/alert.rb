ActiveAdmin.register Notification::Alert do
  menu parent: "System", label: "Alerts", priority: 10

  config.batch_actions = false
  actions :index, :update, :edit, :show

  acts_as_audit

  permit_params send_to: []

  index do
    selectable_column
    id_column
    actions
    column :event
    column :send_to do |r|
      r.contacts.map { |p| p.email }.sort.join(", ")
    end
  end

  form do |f|
    f.inputs do
      f.input :send_to, as: :select, input_html: {class: 'chosen-sortable', multiple: true}, collection: Billing::Contact.collection, hint: f.object.send_to_hint
    end
    f.actions
  end

  show do |s|
    attributes_table do
      row :id
      row :event
      row :send_to do
        s.contacts.map { |p| p.email }.sort.join(", ")
      end
    end
  end

  filter :id

end

