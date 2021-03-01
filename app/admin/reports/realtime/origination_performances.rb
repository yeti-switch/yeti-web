# frozen_string_literal: true

ActiveAdmin.register Report::Realtime::OriginationPerformance do
  menu parent: 'Reports', label: 'Origination performance', priority: 102
  config.batch_actions = false
  config.paginate = false
  config.sort_order = 'customer_auth_id'
  actions :index

  decorate_with ReportRealtimeOriginationPerformanceDecorator

  filter :time_interval_eq, label: 'Time Interval',
                            as: :select,
                            collection: Report::Realtime::Base::INTERVALS,
                            input_html: { class: 'chosen' }, include_blank: false

  filter :customer,
         input_html: { class: 'chosen-ajax', 'data-path': '/contractors/search?q[customer_eq]=true&q[ordered_by]=name' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:customer_id_eq]
           resource_id ? Contractor.where(id: resource_id) : []
         }

  with_default_realtime_interval

  controller do
    def scoped_collection
      lenght = params[:q][:time_interval_eq].to_i
      super.detailed_scope(lenght)
    end
  end

  index do
    column :customer_auth, sortable: :customer_auth_id do |row|
      if !row.customer_auth_id.nil?
        auto_link(row.customer_auth) || status_tag(:unknown)
      else
        status_tag(:not_authenticated, class: :red)
      end
    end

    column :cps, sortable: :cps, &:decorated_cps
    column 'Offered load(Erlang)', :offered_load, sortable: :offered_load, &:decorated_offered_load
    column :routing_delay, sortable: :avg_routing_delay, &:decorated_routing_delay
    column :calls_duration, sortable: :calls_duration, &:decorated_calls_duration

    column :calls_count, sortable: :calls_count
    column :termination_attempts_count, sortable: :termination_attempts_count
    column :acd, sortable: :acd, &:decorated_acd
    column :asr, sortable: :asr, &:decorated_asr
  end
end
