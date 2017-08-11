ActiveAdmin.register Report::CustomCdrScheduler, as: 'CustomCdrScheduler' do
  menu false
  config.batch_actions = false
  actions :index, :destroy, :create, :new

  permit_params :period_id,
                :customer_id,
                :filter,
                :group_by,
                send_to: [],
                group_by: []

  includes :period

  for_report Report::CustomCdr

  index do
    selectable_column
    id_column
    actions
    column :created_at
    column :period
    column :customer
    column :filter
    column :group_by
    column :send_to do |r|
      r.contacts.map { |p| p.email }.sort.join(", ")
    end
    column :last_run_at
    column :next_run_at
  end

  form do |f|
    f.inputs do
      f.input :period
      f.input :customer, as: :select, input_html: {class: 'chosen'}
      f.input :filter
      f.input :group_by, as: :select, input_html: {class: 'chosen-sortable', multiple: true},
              collection:  Report::CustomCdr::CDR_COLUMNS.map{ |a| [a, a] }
      f.input :send_to, as: :select, input_html: {class: 'chosen-sortable', multiple: true}, collection: Billing::Contact.collection, hint: f.object.send_to_hint
    end
    f.actions
  end

  filter :id
  filter :period
  filter :customer, as: :select, input_html: {class: 'chosen'}

end

