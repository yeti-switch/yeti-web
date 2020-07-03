# frozen_string_literal: true

ActiveAdmin.register Report::Realtime::BadRouting do
  menu parent: 'Reports', label: 'Bad routing', priority: 103
  config.batch_actions = false
  config.paginate = false
  config.sort_order = 'customer_auth_id'
  actions :index

  filter :time_interval_eq, label: 'Time Interval',
                            as: :select,
                            collection: Report::Realtime::Base::INTERVALS,
                            input_html: { class: 'chosen' }, include_blank: false

  filter :customer,
         collection: proc {
           resource_id = params.fetch(:q, {})[:customer_id_eq]
           resource_id ? Contractor.where(id: resource_id) : []
         },
         input_html: { class: 'chosen-ajax', 'data-path': '/contractors/search?q[customer_eq]=true&q[ordered_by]=name' }

  filter :rateplan, input_html: { class: 'chosen' }
  filter :routing_plan, input_html: { class: 'chosen' }
  filter :internal_disconnect_code
  filter :internal_disconnect_reason

  with_default_realtime_interval

  controller do
    def scoped_collection
      super.detailed_scope
    end
  end

  index do
    column :customer, sortable: :customer_id do |row|
      auto_link(row.customer) || status_tag(:unknown)
    end
    column :customer_auth, sortable: :customer_auth_id do |row|
      auto_link(row.customer_auth) || status_tag(:unknown)
    end
    column :rateplan, sortable: :rateplan_id do |row|
      auto_link(row.rateplan) || status_tag(:unknown)
    end
    column :routing_plan, sortable: :routing_plan_id do |row|
      auto_link(row.routing_plan) || status_tag(:unknown)
    end
    column :internal_disconnect_code
    column :internal_disconnect_reason

    column :calls_count, sortable: :calls_count
  end
end
