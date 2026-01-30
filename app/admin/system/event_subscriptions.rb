# frozen_string_literal: true

ActiveAdmin.register System::EventSubscription, as: 'Event Subscription' do
  menu parent: 'System', priority: 10
  config.batch_actions = false
  actions :index, :update, :edit, :show
  acts_as_audit

  filter :id

  index do
    selectable_column
    id_column
    actions
    column :event
    column :send_to do |r|
      r.contacts.map(&:email).sort.join(', ')
    end
    column :url
  end

  show do |s|
    attributes_table do
      row :id
      row :event
      row :send_to do
        s.contacts.map(&:email).sort.join(', ')
      end
      row :url
    end
  end

  permit_params :url, send_to: []

  form do |f|
    f.inputs do
      f.input :send_to,
              as: :select,
              input_html: { class: 'tom-select-sortable', multiple: true },
              collection: Billing::Contact.collection,
              hint: f.object.send_to_hint

      f.input :url
    end
    f.actions
  end
end
