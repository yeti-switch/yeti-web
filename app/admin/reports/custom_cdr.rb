ActiveAdmin.register Report::CustomCdr, as: 'CustomCdr' do

  menu parent: "Reports", label: "Custom Cdr report", priority: 10
  config.batch_actions = true
  actions :index, :destroy, :create, :new

  permit_params :date_start,
                :date_end,
                :customer_id,
                :filter,
#                :group_by,
                send_to: [],
                group_by_fields: []

  includes :customer

  controller do
    def create
      create!
    end
  end

  report_scheduler Report::CustomCdrScheduler

  index do
    selectable_column
    id_column
    actions  do |row|
      link_to 'View', custom_cdr_custom_items_path(row)
    end
    column :created_at
    column :date_start
    column :date_end
    column :customer
    column :filter
    column :group_by
  end

  form do |f|
    f.inputs do
      f.input :date_start, as: :date_time_picker, wrapper_html: { class: 'datetime_preset_pair', data: { show_time: 'true' } },
              hint: I18n.t('hints.reports.custom_cdr.date_start')
      f.input :date_end, as: :date_time_picker, hint: I18n.t('hints.reports.custom_cdr.date_end')
      f.input :customer, as: :select, input_html: {class: 'chosen'}, hint: I18n.t('hints.reports.custom_cdr.customer')
      f.input :filter, hint: I18n.t('hints.reports.custom_cdr.filter')
      f.input :group_by_fields, label: "Group by", as: :select, input_html: {class: 'chosen-sortable', multiple: true},
              collection:  Report::CustomCdr::CDR_COLUMNS.map{ |a| [a, a] },
              hint: I18n.t('hints.reports.custom_cdr.group_by_fields')
      f.input :send_to, as: :select, input_html: {class: 'chosen-sortable', multiple: true}, collection: Billing::Contact.collection, hint: f.object.send_to_hint
    end
    f.actions
  end

  filter :id
  filter :date_start, as: :date_time_range
  filter :date_end, as: :date_time_range
  filter :created_at, as: :date_time_range
  filter :customer, as: :select, input_html: {class: 'chosen'}

end

