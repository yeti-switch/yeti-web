# frozen_string_literal: true

ActiveAdmin.register Report::Realtime::TerminationDistribution do
  menu parent: 'Reports', label: 'Termination distribution', priority: 100
  config.batch_actions = false
  config.paginate = false
  config.per_page = 10_000 # scalar: no per-page dropdown (these pages load every row at once)
  config.sort_order = 'vendor_id_desc'
  actions :index

  decorate_with ReportRealtimeTerminationDistributionDecorator

  filter :time_interval_eq, label: 'Time Interval',
                            as: :select,
                            collection: Report::Realtime::Base::INTERVALS,
                            input_html: { class: 'tom-select' }, include_blank: false

  contractor_filter :customer_id_eq, label: 'Customer', path_params: { q: { customer_eq: true } }

  with_default_realtime_interval

  controller do
    def scoped_collection
      super.detailed_scope
    end
  end

  index do
    column :vendor, sortable: :vendor_id do |row|
      auto_link(row.vendor) || row.vendor_id
    end
    column :originated_calls_count, sortable: :originated_calls_count
    column :rerouted_calls_count, sortable: :rerouted_calls_count
    column :rerouted_calls_percent, sortable: :rerouted_calls_percent
    column :termination_attempts_count, sortable: :termination_attempts_count
    column :calls_duration, sortable: :calls_duration
    column :acd, sortable: :acd, &:decorated_acd
    column :origination_asr, sortable: :origination_asr, &:decorated_origination_asr
    column :termination_asr, sortable: :termination_asr, &:decorated_termination_asr
    column :profit, sortable: :profit, &:decorated_profit
    column :customer_price, sortable: :customer_price, &:decorated_customer_price
    column :vendor_price, sortable: :vendor_price, &:decorated_vendor_price
  end

  index as: :data do
    data = collection.map do |x|
      {
        label: x.vendor&.display_name || "Vendor | #{x.vendor_id}",
        value: x.originated_calls_count
      }
    end

    div class: 'd3-chart d3-chart-inline d3-piechart',
        'data-series': data.to_json,
        style: 'height: 600px;'
  end
end
