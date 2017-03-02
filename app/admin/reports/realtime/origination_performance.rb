ActiveAdmin.register Report::Realtime::OriginationPerformance do
  menu parent: 'Reports', label: 'Origination performance', priority: 102
  config.batch_actions = false
  config.paginate = false
  config.sort_order = 'customer_auth_id'
  actions :index


  decorate_with ReportRealtimeOriginationPerformanceDecorator

  filter :time_interval_eq, label: 'Time Interval',
         as: :select,
         collection: [['5 Minutes', 5.minute], ['10 Minutes', 10.minute], ['15 Minutes', 15.minute], ['1 Hour', 1.hour]],
         input_html: {class: 'chosen'}, include_blank: false

  filter :customer_id, label: 'Customer',
         as: :select,
         collection: proc { Contractor.select(:id, :name).reorder(:name) },
         input_html: {class: 'chosen'}

  before_filter only: [:index] do
    params[:q] ||= {}
    if params[:q][:time_interval_eq].blank?
      params[:q][:time_interval_eq] = 5.minute
      flash.now[:notice_message] = 'Records for time interval 5 minutes are displayed by default'
    end
  end

  controller do
    def scoped_collection
      lenght=params[:q][:time_interval_eq].to_i
      super.detailed_scope(lenght)
    end
  end

  index do
    column :customer_auth, sortable: :customer_auth_id do |row|
      if !row.customer_auth_id.nil?
        auto_link(row.customer_auth) || status_tag(:unknown)
      else
        status_tag(:not_authenticated,:red)
      end
    end

    column :cps, sortable: :cps do |c|
      c.decorated_cps
    end
    column 'Offered load(Erlang)', :offered_load, sortable: :offered_load do |c|
      c.decorated_offered_load
    end
    column :routing_delay, sortable: :avg_routing_delay do |c|
      c.decorated_routing_delay

    end
    column :calls_duration, sortable: :calls_duration do |c|
      c.decorated_calls_duration
    end

    column :calls_count, sortable: :calls_count
    column :termination_attempts_count, sortable: :termination_attempts_count
    column :acd, sortable: :acd do |c|
      c.decorated_acd
    end
    column :asr, sortable: :asr do |c|
      c.decorated_asr
    end
  end


end