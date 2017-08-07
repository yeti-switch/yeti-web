ActiveAdmin.register Destination do

  menu parent: "Routing", priority: 41

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status
  acts_as_quality_stat
  acts_as_stats_actions

  decorate_with DestinationDecorator

  acts_as_export :id, :enabled, :prefix,
                 [:rateplan_name, proc { |row| row.rateplan.try(:name) }],
                 [:routing_tag_name, proc { |row| row.routing_tag.try(:name) }],
                 :reject_calls,
                 [:rate_policy_name, proc { |row| row.rate_policy.try(:name) }],
                 :initial_interval, :next_interval,
                 :use_dp_intervals,
                 :initial_rate, :next_rate, :connect_fee,
                 :dp_margin_fixed, :dp_margin_percent,
                 [:profit_control_mode_name, proc { |row| row.profit_control_mode.try(:name) }],
                 :valid_from, :valid_till,
                 :asr_limit, :acd_limit, :short_calls_limit

  acts_as_import resource_class: Importing::Destination
  acts_as_batch_changeable [:enabled, :initial_interval,:next_interval, :initial_rate, :next_rate, :connect_fee,
                            :dp_margin_fixed, :dp_margin_percent ]

  scope :low_quality


  filter :id
  filter :enabled, as: :select , collection: [ ["Yes", true], ["No", false]]
  filter :prefix
  filter :routing_for_contains, as: :string, input_html: {class: 'search_filter_string'}
  filter :rateplan, input_html: { class: 'chosen'}
  filter :routing_tag, input_html: { class: 'chosen'}
  filter :reject_calls, as: :select , collection: [ ["Yes", true], ["No", false]]
  filter :initial_rate
  filter :next_rate
  filter :connect_fee
  filter :network_prefix_country_id_eq,
         label: 'Country',
         input_html: {class: 'chosen',
                      onchange: remote_chosen_request(:get, 'system_countries/get_networks', {country_id: "$(this).val()"}, :q_network_prefix_network_id_eq)

         },
         as: :select, collection: ->{ System::Country.all }


  filter :network_prefix_network_id_eq,
         label: 'Network',
         input_html: {class: 'chosen'},
         as: :select,
         collection: -> {
           System::Country.find(assigns["search"].network_prefix_country_id_eq).networks rescue []

         }

  filter :external_id_eq, label: 'EXTERNAL_ID'



  permit_params :enabled, :prefix, :rateplan_id, :next_rate, :connect_fee,
                :initial_interval, :next_interval, :dp_margin_fixed,
                :dp_margin_percent, :rate_policy_id, :initial_rate,
                :reject_calls, :use_dp_intervals, :test, :profit_control_mode_id,
                :valid_from, :valid_till, :asr_limit, :acd_limit, :short_calls_limit, :batch_prefix, :routing_tag_id

  includes :rateplan, :rate_policy, :profit_control_mode, :routing_tag, network_prefix: [:country, :network]


  member_action :clear_quality_alarm do
    #todo  cancan support   ?
    if can? :manage, resource
      resource = Destination.find(params[:id])
      resource.clear_quality_alarm
      flash[:notice] = "#{active_admin_config.resource_label} Alarm cleared"
    end
    redirect_to(:back)
  end

  action_item :clear_quality_alarm, only: [:show, :edit] do
    if resource.quality_alarm? && can?(:manage, resource)
      link_to 'Clear quality alarm', action: :clear_quality_alarm, id: resource.id
    end
  end


  index do
    selectable_column
    id_column
    actions
    column :enabled
    column :prefix
    column :country, sortable: 'countries.name' do |row|
      auto_link row.network_prefix.try!(:country)
    end
    column :network, sortable: 'networks.name' do |row|
      auto_link row.network_prefix.try!(:network)
    end

    column :reject_calls
    column :quality_alarm
    column :rateplan, sortable: 'rateplans.name'
    column :routing_tag, sortable: 'routing_tags.name'
    column :valid_from do |c|
      c.decorated_valid_from
    end
    column :valid_till do |c|
      c.decorated_valid_till
    end

    column :rate_policy

    ## fixed price
    column :initial_interval
    column :initial_rate
    column :next_interval
    column :next_rate
    column :connect_fee
    column :use_dp_intervals

    #cost + X ( $ or % )
    column :dp_margin_fixed
    column :dp_margin_percent
    column :profit_control_mode
    column :external_id

    column :asr_limit
    column :acd_limit
    column :short_calls_limit
  end

  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      if f.object.new_record? # allow multiple prefixes delimited by comma in NEW form.
        f.input :batch_prefix, label: "Prefix", input_html: {class: :prefix_detector} , hint: f.object.network_details_hint
      else
        f.input :prefix, label: "Prefix", input_html: {class: :prefix_detector} , hint: f.object.network_details_hint
      end
      f.input :enabled
      f.input :reject_calls
      f.input :rateplan, input_html: { class: 'chosen'}, hint: I18n.t('hints.routing.destinations.rateplan')
      f.input :routing_tag, input_html: {class: 'chosen'}, include_blank: "None", hint: I18n.t('hints.routing.destinations.routing_tag')
      f.input :valid_from, as: :date_time_picker, hint: I18n.t('hints.routing.destinations.valid_from')
      f.input :valid_till, as: :date_time_picker, hint: I18n.t('hints.routing.destinations.valid_till')
      f.input :rate_policy, hint: I18n.t('hints.routing.destinations.rate_policy')
      f.input :initial_interval, hint: I18n.t('hints.routing.destinations.initial_interval')
      f.input :next_interval, hint: I18n.t('hints.routing.destinations.next_interval')
      f.input :use_dp_intervals
    end
    f.inputs "Fixed rating configuration" do
      f.input :initial_rate, hint: I18n.t('hints.routing.destinations.initial_rate')
      f.input :next_rate, hint: I18n.t('hints.routing.destinations.next_rate')
      f.input :connect_fee, hint: I18n.t('hints.routing.destinations.connect_fee')
      f.input :profit_control_mode, hint: I18n.t('hints.routing.destinations.profit_control_mode')
    end

    f.inputs "Dialpeer based rating configuration" do
      f.input :dp_margin_fixed, hint: I18n.t('hints.routing.destinations.dp_margin_fixed')
      f.input :dp_margin_percent, hint: I18n.t('hints.routing.destinations.dp_margin_percent')
    end

    f.inputs "Quality notifications configuration" do
      f.input :asr_limit, hint: I18n.t('hints.routing.destinations.asr_limit')
      f.input :acd_limit, hint: I18n.t('hints.routing.destinations.acd_limit')
      f.input :short_calls_limit, hint: I18n.t('hints.routing.destinations.short_calls_limit')
    end
    f.actions
  end

  show do |s|
    attributes_table do
      row :enabled
      row :prefix
      row :country
      row :network
      row :reject_calls
      row :quality_alarm
      row :rateplan
      row :routing_tag
      row :valid_from do |c|
        c.decorated_valid_from
      end
      row :valid_till do |c|
        c.decorated_valid_till
      end
      row :rate_policy
      row :initial_interval
      row :next_interval
      row :use_dp_intervals
      row "external id" do |c|
        c.external_id
      end
    end
    panel "Fixed rating configuration" do
      attributes_table_for s do
        row :initial_rate
        row :next_rate
        row :connect_fee
        row :profit_control_mode
      end
    end
    panel "Dialpeer based rating configuration" do
      attributes_table_for s do
        row :dp_margin_fixed
        row :dp_margin_percent
      end
    end
    panel "Quality notifications configuration" do
      attributes_table_for s do
        row :asr_limit
        row :acd_limit
        row :short_calls_limit
      end
    end
    active_admin_comments
  end
end
