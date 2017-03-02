ActiveAdmin.register Report::Realtime::BadRouting do
  menu parent: 'Reports', label: 'Bad routing', priority: 103
  config.batch_actions = false
  config.paginate = false
  config.sort_order = 'customer_auth_id'
  actions :index

  filter :time_interval_eq, label: 'Time Interval',
         as: :select,
         collection: [['5 Minutes', 5.minute], ['10 Minutes', 10.minute], ['15 Minutes', 15.minute], ['1 Hour', 1.hour]],
         input_html: {class: 'chosen'}, include_blank: false

  filter :customer_id, label: 'Customer',
         as: :select,
         collection: proc { Contractor.select(:id, :name).reorder(:name) },
         input_html: {class: 'chosen'}

  filter :rateplan, input_html: {class: 'chosen'}
  filter :routing_plan, input_html: {class: 'chosen'}
  filter :internal_disconnect_code
  filter :internal_disconnect_reason

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