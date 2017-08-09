ActiveAdmin.register Dialpeer do

  menu parent: "Routing", priority: 51


  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status
  acts_as_stat
  acts_as_quality_stat
  acts_as_lock
  acts_as_stats_actions

  decorate_with DialpeerDecorator

  scope :locked


  #"Id","Enabled","Prefix","Rateplan","Rate","Connect Fee"
  acts_as_export :id, :enabled, :locked, :prefix, :priority, :force_hit_rate, :exclusive_route,
                 :initial_interval, :initial_rate, :next_interval,  :next_rate, :connect_fee,
                 :lcr_rate_multiplier,
                 [:gateway_name, proc { |row| row.gateway.try(:name) }],
                 [:gateway_group_name, proc { |row| row.gateway_group.try(:name) }],
                 [:routing_group_name, proc { |row| row.routing_group.try(:name) }],
                 [:vendor_name, proc { |row| row.vendor.try(:name) }],
                 [:account_name, proc { |row| row.account.try(:name) }],
                 :valid_from, :valid_till,
                 :acd_limit, :asr_limit, :short_calls_limit, :capacity,
                 :src_rewrite_rule, :src_rewrite_result,
                 :dst_rewrite_rule, :dst_rewrite_result,
                 :created_at

  acts_as_import resource_class: Importing::Dialpeer
  
  acts_as_batch_changeable [:enabled, :priority, :initial_interval, :next_interval,
                            :initial_rate, :next_rate, :connect_fee,
                            :lcr_rate_multiplier, :force_hit_rate,
                            :capacity, :acd_limit, :asr_limit, :short_calls_limit,
                            :src_rewrite_rule, :src_rewrite_result,
                            :dst_rewrite_rule, :dst_rewrite_result
                           ]


  controller do
    def resource_params
      return [] if request.get?
      [ params[active_admin_config.resource_class.name.underscore.to_sym].permit! ]
    end

  end

  includes :gateway, :gateway_group, :routing_group, :vendor, :account, :statistic, :routing_tag, network_prefix: [:country, :network]

  action_item :show_rates, only: [:show] do
    link_to 'Show Rates', dialpeer_dialpeer_next_rates_path(resource.id)
  end

  action_item :new_rate, only: [:show] do
    link_to 'New Rate', new_dialpeer_dialpeer_next_rate_path(resource.id)
  end


  index do
    selectable_column
    actions
    id_column

    column :enabled
    column :locked
    column :prefix
    column :country, sortable: 'countries.name' do |row|
      auto_link row.network_prefix.try!(:country)
    end
    column :network, sortable: 'networks.name' do |row|
      auto_link row.network_prefix.try!(:network)
    end
    column :routing_group, sortable: 'routing_groups.name'
    column :routing_tag, sortable: 'routing_tags.name'
    column :priority
    column :force_hit_rate
    column :exclusive_route
    column :initial_interval
    column :initial_rate
    column :next_interval
    column :next_rate
    column :connect_fee
    column :lcr_rate_multiplier
    column :gateway, sortable: 'gateways.name' do |c|
      auto_link(c.gateway, c.gateway.decorated_termination_display_name) unless c.gateway.nil?
    end
    column :gateway_group do |c|
      auto_link(c.gateway_group, c.gateway_group.decorated_display_name) unless c.gateway_group.nil?
    end
    column :vendor, sortable: 'contractor.name' do |c|
      auto_link(c.vendor, c.vendor.decorated_vendor_display_name)
    end
    column :account, sortable: 'accounts.id' do |c|
      auto_link(c.account, c.account.decorated_vendor_display_name)
    end
    column :valid_from do |c|
      c.decorated_valid_from
    end
    column :valid_till do |c|
      c.decorated_valid_till
    end

    column :capacity

    column :calls, sortable: 'dialpeers_stats.calls' do |row|
      row.statistic.try(:calls)
    end
    column :total_duration, sortable: 'dialpeers_stats.total_duration' do |row|
      "#{row.statistic.try(:total_duration) || 0} sec."
    end

    column :asr, sortable: 'dialpeers_stats.asr' do |row|
      row.statistic.try(:asr)
    end
    column :asr_limit
    column :acd, sortable: 'dialpeers_stats.acd' do |row|
      row.statistic.try(:acd)
    end
    column :acd_limit
    column :short_calls_limit
    column :src_rewrite_rule
    column :src_rewrite_result
    column :dst_rewrite_rule
    column :dst_rewrite_result
    column :created_at
    column :external_id
  end

  filter :id
  filter :prefix
  filter :routing_for_contains, as: :string , input_html: {class: 'search_filter_string'}
  filter :enabled, as: :select, collection: [["Yes", true], ["No", false]]
  filter :vendor, input_html: {class: 'chosen'}
  filter :account, input_html: {class: 'chosen'}
  filter :gateway, input_html: {class: 'chosen'}
  filter :gateway_group, input_html: {class: 'chosen'}
  filter :routing_group, input_html: {class: 'chosen'}
  filter :routing_tag, input_html: {class: 'chosen'}
  filter :routing_group_routing_plans_id_eq, as: :select, input_html: {class: 'chosen'}, label: "Routing Plan", collection: -> { Routing::RoutingPlan.all }

  filter :locked, as: :select, collection: [["Yes", true], ["No", false]]
  filter :valid_from, as: :date_time_range
  filter :valid_till, as: :date_time_range
  filter :statistic_calls, as: :numeric
  filter :statistic_total_duration, as: :numeric
  filter :statistic_asr, as: :numeric
  filter :statistic_acd, as: :numeric
  filter :force_hit_rate
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
  filter :created_at, as: :date_time_range
  filter :external_id
  filter :exclusive_route, as: :select, collection: [["Yes", true], ["No", false]]


  form do |f|
    f.semantic_errors *f.object.errors.keys
    f.inputs form_title do
      if f.object.new_record? # allow multiple prefixes delimited by comma in NEW form.
        f.input :batch_prefix, label: "Prefix", input_html: {class: :prefix_detector} , hint: f.object.network_details_hint
      else
        f.input :prefix, label: "Prefix", input_html: {class: :prefix_detector} , hint: f.object.network_details_hint
      end

      f.input :enabled
      f.input :routing_group, input_html: {class: 'chosen'}, hint: I18n.t('hints.routing.dialpeers.routing_group')
      f.input :routing_tag, input_html: {class: 'chosen'}, include_blank: "None", hint: I18n.t('hints.routing.dialpeers.routing_tag')
      f.input :vendor,  collection: Contractor.vendors,
              input_html: {
                  class: 'chosen',
                  onchange: remote_chosen_request(:get, with_contractor_accounts_path, {contractor_id: "$(this).val()"}, :dialpeer_account_id) +
                      remote_chosen_request(:get, with_contractor_gateways_path, {contractor_id: "$(this).val()"}, :dialpeer_gateway_id) +
                      remote_chosen_request(:get, with_contractor_gateway_groups_path, {contractor_id: "$(this).val()"}, :dialpeer_gateway_group_id)
              },
              hint: I18n.t('hints.routing.dialpeers.vendor')
      f.input :account, collection: (f.object.vendor.nil? ? [] : f.object.vendor.accounts),
              include_blank: false,
              input_html: {class: 'chosen'},
              hint: I18n.t('hints.routing.dialpeers.account')
      f.input :priority, hint: I18n.t('hints.routing.dialpeers.priority')
      f.input :force_hit_rate, hint: I18n.t('hints.routing.dialpeers.force_hit_rate')
      f.input :exclusive_route
      f.input :initial_interval, hint: I18n.t('hints.routing.dialpeers.initial_interval')
      f.input :initial_rate, hint: I18n.t('hints.routing.dialpeers.initial_rate')
      f.input :next_interval, hint: I18n.t('hints.routing.dialpeers.next_interval')
      f.input :next_rate, hint: I18n.t('hints.routing.dialpeers.next_rate')
      f.input :lcr_rate_multiplier, hint: I18n.t('hints.routing.dialpeers.lcr_rate_multiplier')
      f.input :connect_fee, hint: I18n.t('hints.routing.dialpeers.connect_fee')

      f.input :gateway, collection: (f.object.vendor.nil? ? [] : f.object.vendor.gateways),
              include_blank: "None" ,
              input_html: {class: 'chosen'},
              hint: I18n.t('hints.routing.dialpeers.gateway')
      f.input :gateway_group, collection: (f.object.vendor.nil? ? [] : f.object.vendor.gateway_groups),
              include_blank: "None" ,
              input_html: {class: 'chosen'},
              hint: I18n.t('hints.routing.dialpeers.gateway_group')

      f.input :valid_from, as: :date_time_picker, hint: I18n.t('hints.routing.dialpeers.valid_from')
      f.input :valid_till, as: :date_time_picker, hint: I18n.t('hints.routing.dialpeers.valid_till')
      f.input :acd_limit, hint: I18n.t('hints.routing.dialpeers.acd_limit')
      f.input :asr_limit, hint: I18n.t('hints.routing.dialpeers.asr_limit')
      f.input :short_calls_limit, hint: I18n.t('hints.routing.dialpeers.short_calls_limit')
      f.input :capacity, hint: I18n.t('hints.routing.dialpeers.capacity')
      f.input :src_name_rewrite_rule, hint: I18n.t('hints.routing.dialpeers.src_name_rewrite_rule')
      f.input :src_name_rewrite_result, hint: I18n.t('hints.routing.dialpeers.src_name_rewrite_result')
      f.input :src_rewrite_rule, hint: I18n.t('hints.routing.dialpeers.src_rewrite_rule')
      f.input :src_rewrite_result, hint: I18n.t('hints.routing.dialpeers.src_rewrite_result')
      f.input :dst_rewrite_rule, hint: I18n.t('hints.routing.dialpeers.dst_rewrite_rule')
      f.input :dst_rewrite_result, hint: I18n.t('hints.routing.dialpeers.dst_rewrite_result')
    end
    f.actions
  end
  
  show do |s|
    tabs do

      tab :general do
        attributes_table do
          row :prefix
          row :country
          row :network
          row :enabled
          row :locked
          row :routing_group
          row :routing_tag
          row :vendor do
            auto_link(s.vendor, s.vendor.decorated_vendor_display_name)
          end
          row :account do
            auto_link(s.account, s.account.decorated_vendor_display_name)
          end
          row :priority
          row :force_hit_rate
          row :exclusive_route
          row :initial_interval
          row :initial_rate
          row :next_interval
          row :next_rate
          row :lcr_rate_multiplier
          row :connect_fee

          row :gateway do
            auto_link(s.gateway, s.gateway.decorated_termination_display_name) unless s.gateway.nil?
          end
          row :gateway_group do
            auto_link(s.gateway_group, s.gateway_group.decorated_display_name) unless s.gateway_group.nil?
          end
          row :valid_from do
            s.decorated_valid_from
          end
          row :valid_till do
            s.decorated_valid_till
          end
          row :capacity
          row :src_name_rewrite_rule
          row :src_name_rewrite_result
          row :src_rewrite_rule
          row :src_rewrite_result
          row :dst_rewrite_rule
          row :dst_rewrite_result
          row :acd_limit
          row :asr_limit
          row :short_calls_limit
          row :created_at
          row :external_id
          row :current_rate_id
        end
      end

      tab :termination_chart do
        panel 'PDD Distribution' do
          render partial: 'charts/dialpeer_pdd_distribution'
        end
      end

      tab :upcoming_price_changes do
        table_for s.dialpeer_next_rates.not_applied.order(apply_time: :asc).limit(10) do
          column :apply_time
          column :initial_interval
          column :next_interval
          column :rate
          column :connect_fee
          column :external_id
          column :actions do |r|
            link_to('Edit', edit_dialpeer_dialpeer_next_rate_path(s.id, r.id))
          end
        end
      end

    end
    active_admin_comments
  end


end
