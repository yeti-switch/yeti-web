ActiveAdmin.register Report::Realtime::TerminationDistribution do
  menu parent: 'Reports', label: 'Termination distribution', priority: 100
  config.batch_actions = false
  config.paginate = false
  config.sort_order = 'vendor_id_desc'
  actions :index

  decorate_with ReportRealtimeTerminationDistributionDecorator

  filter :time_interval_eq, label: 'Time Interval',
         as: :select,
         collection: Report::Realtime::Base::INTERVALS,
         input_html: {class: 'chosen'}, include_blank: false

  filter :customer_id, label: 'Customer',
         as: :select, collection: proc { Contractor.select(:id, :name).reorder(:name) },
         input_html: {class: 'chosen'}

  before_filter only: [:index] do
    params[:q] ||= {}
    if params[:q][:time_interval_eq].blank?
      params[:q][:time_interval_eq] = Report::Realtime::Base::DEFAULT_INTERVAL
      flash.now[:notice_message] = "Records for time interval #{Report::Realtime::Base::DEFAULT_INTERVAL} seconds are displayed by default"
    end
  end

  controller do
    def scoped_collection
      super.detailed_scope
    end

    def find_collection
      @skip_drop_down_pagination = true
      super
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
    column :acd, sortable: :acd do |c|
      c.decorated_acd
    end
    column :origination_asr, sortable: :origination_asr do |c|
      c.decorated_origination_asr
    end
    column :termination_asr, sortable: :termination_asr do |c|
      c.decorated_termination_asr
    end
    column :profit, sortable: :profit do |c|
      c.decorated_profit
    end
    column :customer_price, sortable: :customer_price do |c|
      c.decorated_customer_price
    end
    column :vendor_price, sortable: :vendor_price do |c|
      c.decorated_vendor_price
    end
  end

  index as: :data, skip_drop_down_pagination: true do

    data = collection.map do |x|
      {
          label: x.vendor.try!(:display_name) || "Vendor | #{x.vendor_id}",
          value: x.originated_calls_count
      }
    end

    div class: 'd3-chart d3-chart-inline d3-piechart',
        'data-series': data.to_json,
        style: 'height: 600px;'
  end


end
