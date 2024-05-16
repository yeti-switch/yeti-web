# frozen_string_literal: true

ActiveAdmin.register Routing::Destination, as: 'Destination' do
  menu parent: 'Routing', priority: 45

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status(show_count: false)
  acts_as_quality_stat
  acts_as_stats_actions
  acts_as_async_destroy('Routing::Destination')
  acts_as_async_update BatchUpdateForm::Destination

  scoped_collection_action :async_schedule_rate_changes,
                           title: 'Schedule rate changes',
                           class: 'scoped_collection_action_button ui',
                           form: -> { Destination::ScheduleRateChangesForm.form_inputs },
                           if: -> { authorized?(:batch_update, resource_klass) } do
    attrs = params[:changes]&.permit(:apply_time, :initial_interval, :initial_rate, :next_interval, :next_rate, :connect_fee)

    form = Destination::ScheduleRateChangesForm.new(attrs)
    form.ids_sql = scoped_collection_records.select(:id).to_sql

    if form.save
      flash[:notice] = 'Rate changes are scheduled'
    else
      flash[:error] = "Validation Error: #{form.errors.full_messages.to_sentence}"
    end

    head 200
  end

  acts_as_delayed_job_lock

  decorate_with DestinationDecorator

  acts_as_export :id, :enabled, :prefix, :dst_number_min_length, :dst_number_max_length,
                 [:rate_group_name, proc { |row| row.rate_group.try(:name) }],
                 :reject_calls,
                 :rate_policy_name,
                 :initial_interval, :next_interval,
                 :use_dp_intervals,
                 :initial_rate, :next_rate, :connect_fee,
                 :dp_margin_fixed, :dp_margin_percent,
                 :profit_control_mode_name,
                 :valid_from, :valid_till,
                 :asr_limit, :acd_limit, :short_calls_limit, :reverse_billing,
                 [:routing_tag_names, proc { |row| row.model.routing_tags.map(&:name).join(', ') }],
                 [:routing_tag_mode_name, proc { |row| row.routing_tag_mode.try(:name) }]

  acts_as_import resource_class: Importing::Destination,
                 skip_columns: [:routing_tag_ids]

  scope :low_quality
  scope :time_valid

  filter :id
  filter :uuid_equals, label: 'UUID'
  filter :enabled, as: :select, collection: [['Yes', true], ['No', false]]
  filter :prefix
  filter :routing_for_contains, as: :string, input_html: { class: 'search_filter_string' }
  filter :rate_group, input_html: { class: 'chosen' }
  filter :rate_group_rateplans_id_eq, as: :select, input_html: { class: 'chosen' }, label: 'Rateplan', collection: -> { Routing::Rateplan.all }
  filter :reject_calls, as: :select, collection: [['Yes', true], ['No', false]]
  filter :initial_rate
  filter :next_rate
  filter :connect_fee

  filter :network_prefix_country_id_eq,
         as: :select,
         label: 'Country',
         input_html: {
           class: 'chosen network_prefix_country_id_eq-filter'
         },
         collection: -> { System::Country.order(:name) }

  association_ajax_filter :network_prefix_network_id_eq,
                          label: 'Network',
                          scope: -> { System::Network.order(:name) },
                          path: '/system_networks/search',
                          input_html: {
                            'data-path-params': { 'q[country_id_eq]': '.network_prefix_country_id_eq-filter' }.to_json,
                            'data-required-param': 'q[country_id_eq]'
                          },
                          fill_params: lambda {
                            { country_id_eq: params.dig(:q, :network_prefix_country_id_eq) }
                          }

  filter :external_id_eq, label: 'EXTERNAL_ID'
  filter :valid_from, as: :date_time_range
  filter :valid_till, as: :date_time_range
  filter :rate_policy_id_eq, input_html: { class: 'chosen' }, collection: Routing::DestinationRatePolicy::POLICIES.invert
  boolean_filter :reverse_billing
  filter :initial_interval
  filter :next_interval
  filter :asr_limit
  filter :acd_limit
  filter :short_calls_limit

  acts_as_filter_by_routing_tag_ids routing_tag_ids_count: true

  permit_params :enabled, :prefix, :dst_number_min_length, :dst_number_max_length, :rate_group_id, :next_rate, :connect_fee,
                :initial_interval, :next_interval, :dp_margin_fixed,
                :dp_margin_percent, :rate_policy_id, :reverse_billing, :initial_rate,
                :reject_calls, :use_dp_intervals, :test, :profit_control_mode_id,
                :valid_from, :valid_till, :asr_limit, :acd_limit, :short_calls_limit, :batch_prefix,
                :reverse_billing, :routing_tag_mode_id, routing_tag_ids: []

  action_item :show_rates, only: [:show] do
    link_to 'Show Rates', destination_destination_next_rates_path(resource.id)
  end

  action_item :new_rate, only: [:show] do
    link_to 'New Rate', new_destination_destination_next_rate_path(resource.id)
  end

  action_item :next_rates, only: [:index] do
    link_to 'Next rates', destination_next_rates_path
  end

  controller do
    def update
      if params[:routing_destination][:routing_tag_ids].nil?
        params[:routing_destination][:routing_tag_ids] = []
      end
      super
    end

    # Better not to use includes, because it generates select count(*) from (select distinct ...) queries and such queries very slow
    # see https://github.com/rails/rails/issues/42331
    # https://github.com/yeti-switch/yeti-web/pull/985
    #
    # preload have more controllable behavior, but sorting by associated tables not possible
    def scoped_collection
      super.preload(:rate_group, :routing_tag_mode, network_prefix: %i[country network])
    end
  end

  member_action :clear_quality_alarm do
    DestinationQualityCheck.new(resource.model).clear_quality_alarm
    flash[:notice] = "#{active_admin_config.resource_label} Alarm cleared"
    redirect_back fallback_location: root_path
  end

  action_item :clear_quality_alarm, only: %i[show edit] do
    if resource.quality_alarm? && authorized?(:clear_quality_alarm)
      link_to 'Clear quality alarm', action: :clear_quality_alarm, id: resource.id
    end
  end

  index do
    selectable_column
    id_column
    actions
    column :enabled
    column :prefix
    column :dst_number_length do |c|
      c.dst_number_min_length == c.dst_number_max_length ? c.dst_number_min_length.to_s : "#{c.dst_number_min_length}..#{c.dst_number_max_length}"
    end
    column :country do |row|
      auto_link row.network_prefix&.country
    end
    column :network do |row|
      auto_link row.network_prefix&.network
    end

    column :reject_calls
    column :quality_alarm
    column :rate_group
    column :routing_tags
    column :valid_from, &:decorated_valid_from
    column :valid_till, &:decorated_valid_till

    column :rate_policy, &:rate_policy_name
    column :reverse_billing

    ## fixed price
    column :initial_interval
    column :initial_rate
    column :next_interval
    column :next_rate
    column :connect_fee
    column :use_dp_intervals

    # cost + X ( $ or % )
    column :dp_margin_fixed
    column :dp_margin_percent
    column :profit_control_mode, &:profit_control_mode_name
    column :external_id

    column :asr_limit
    column :acd_limit
    column :short_calls_limit

    column :uuid
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names
    f.inputs form_title do
      if f.object.new_record? # allow multiple prefixes delimited by comma in NEW form.
        f.input :batch_prefix, label: 'Prefix',
                               input_html: { class: :prefix_detector, value: f.object.batch_prefix || f.object.prefix },
                               hint: f.object.network_details_hint
      else
        f.input :prefix, label: 'Prefix', input_html: { class: :prefix_detector }, hint: f.object.network_details_hint
      end
      f.input :dst_number_min_length
      f.input :dst_number_max_length
      f.input :enabled
      f.input :reject_calls
      f.input :rate_group, input_html: { class: 'chosen' }

      f.input :routing_tag_ids, as: :select,
                                collection: routing_tag_options,
                                include_hidden: false,
                                input_html: { class: 'chosen', multiple: true }
      f.input :routing_tag_mode

      f.input :valid_from, as: :date_time_picker
      f.input :valid_till, as: :date_time_picker
      f.input :rate_policy_id, as: :select, include_blank: false, collection: Routing::DestinationRatePolicy::POLICIES.invert
      f.input :reverse_billing
      f.input :initial_interval
      f.input :next_interval
      f.input :use_dp_intervals
    end
    f.inputs 'Fixed rating configuration' do
      f.input :initial_rate
      f.input :next_rate
      f.input :connect_fee
      f.input :profit_control_mode_id,
              as: :select,
              include_blank: true,
              collection: Routing::RateProfitControlMode::MODES.invert,
              hint: 'Leave it empty to inherit Profit control mode from Rateplan'
    end

    f.inputs 'Dialpeer based rating configuration' do
      f.input :dp_margin_fixed
      f.input :dp_margin_percent
    end

    f.inputs 'Quality notifications configuration' do
      f.input :asr_limit
      f.input :acd_limit
      f.input :short_calls_limit
    end

    f.actions
  end

  show do |s|
    tabs do
      tab :general do
        attributes_table do
          row :id
          row :uuid
          row :enabled
          row :prefix
          row :dst_number_min_length
          row :dst_number_max_length
          row :country
          row :network
          row :reject_calls
          row :quality_alarm
          row :rate_group
          row :routing_tags
          row :routing_tag_mode
          row :valid_from, &:decorated_valid_from
          row :valid_till, &:decorated_valid_till
          row :rate_policy, &:rate_policy_name
          row :reverse_billing
          row :initial_interval
          row :next_interval
          row :use_dp_intervals
          row 'external id', &:external_id
        end
        panel 'Fixed rating configuration' do
          attributes_table_for s do
            row :initial_rate
            row :next_rate
            row :connect_fee
            row :profit_control_mode, &:profit_control_mode_name
          end
        end
        panel 'Dialpeer based rating configuration' do
          attributes_table_for s do
            row :dp_margin_fixed
            row :dp_margin_percent
          end
        end
        panel 'Quality notifications configuration' do
          attributes_table_for s do
            row :asr_limit
            row :acd_limit
            row :short_calls_limit
          end
        end
      end

      tab :upcoming_price_changes do
        table_for s.destination_next_rates.not_applied.order(apply_time: :asc).limit(10) do
          column :apply_time
          column :initial_rate
          column :next_rate
          column :initial_interval
          column :next_interval
          column :connect_fee
          column :external_id
          column :actions do |r|
            link_to('Edit', edit_destination_destination_next_rate_path(s.id, r.id))
          end
        end
      end
    end

    active_admin_comments
  end
end
