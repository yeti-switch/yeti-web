ActiveAdmin.register Report::Realtime::NotAuthenticated do
  menu parent: 'Reports', label: 'Not authenticated attempts', priority: 104
  config.batch_actions = false
  config.paginate = false
  config.sort_order = 'customer_auth_id'
  actions :index

  filter :time_interval_eq, label: 'Time Interval',
         as: :select,
         collection: Report::Realtime::Base::INTERVALS,
         input_html: {class: 'chosen'}, include_blank: false


  before_filter only: [:index] do
    params[:q] ||= {}
    if params[:q][:time_interval_eq].blank?
      params[:q][:time_interval_eq] = Report::Realtime::Base::DEFAULT_INTERVAL
      flash.now[:notice_message] = "Records for time interval #{Report::Realtime::Base::DEFAULT_INTERVAL} seconds are displayed by default"
    end
  end

  controller do
    def scoped_collection
      lenght=params[:q][:time_interval_eq].to_i
      super.detailed_scope(lenght)
    end
  end

  index do
    column :auth_orig_ip
    column :auth_orig_port
    column :attempts_count, sortable: :attempts_count
    column :internal_disconnect_code
    column :internal_disconnect_reason
  end


end