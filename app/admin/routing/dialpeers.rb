# frozen_string_literal: true

ActiveAdmin.register Dialpeer do
  menu parent: 'Routing', priority: 51

  acts_as_audit
  acts_as_clone
  acts_as_safe_destroy
  acts_as_status(show_count: false)
  acts_as_stat
  acts_as_quality_stat
  acts_as_lock DialpeerQualityCheck
  acts_as_stats_actions
  acts_as_async_destroy('Dialpeer')
  acts_as_async_update BatchUpdateForm::Dialpeer

  acts_as_good_job_lock

  decorate_with DialpeerDecorator

  scope :locked
  scope :expired
  scope :scheduled, show_count: false

  # "Id","Enabled","Prefix","Rateplan","Rate","Connect Fee"
  acts_as_export :id, :enabled, :locked,
                 [:scheduler_name, proc { |row| row.scheduler.try(:name) }],
                 :prefix, :priority, :force_hit_rate, :exclusive_route,
                 :initial_interval, :initial_rate, :next_interval, :next_rate, :connect_fee,
                 :lcr_rate_multiplier,
                 [:gateway_name, proc { |row| row.gateway.try(:name) }],
                 [:gateway_group_name, proc { |row| row.gateway_group.try(:name) }],
                 [:routing_group_name, proc { |row| row.routing_group.try(:name) }],
                 [:vendor_name, proc { |row| row.vendor.try(:name) }],
                 [:account_name, proc { |row| row.account.try(:name) }],
                 [:routeset_discriminator_name, proc { |row| row.routeset_discriminator.try(:name) }],
                 :valid_from, :valid_till,
                 :acd_limit, :asr_limit, :short_calls_limit, :capacity,
                 :src_name_rewrite_rule, :src_name_rewrite_result,
                 :src_rewrite_rule, :src_rewrite_result,
                 :dst_rewrite_rule, :dst_rewrite_result,
                 :reverse_billing,
                 [:routing_tag_names, proc { |row| row.model.routing_tags.map(&:name).join(', ') }],
                 [:routing_tag_mode_name, proc { |row| row.routing_tag_mode.try(:name) }]

  acts_as_import resource_class: Importing::Dialpeer,
                 skip_columns: [:routing_tag_ids]

  controller do
    def resource_params
      return [{}] if request.get?

      [params[active_admin_config.resource_class.name.underscore.to_sym].permit!]
    end

    def update
      if params['dialpeer']['routing_tag_ids'].nil?
        params['dialpeer']['routing_tag_ids'] = []
      end
      super
    end

    # Better not to use includes, because it generates select count(*) from (select distinct ...) queries and such queries very slow
    # see https://github.com/rails/rails/issues/42331
    # https://github.com/yeti-switch/yeti-web/pull/985
    #
    # preload have more controllable behavior, but sorting by associated tables not possible
    def scoped_collection
      super.preload(:gateway, :gateway_group, :routing_group, :routing_tag_mode, :vendor, :account, :statistic,
                    :routeset_discriminator, network_prefix: %i[country network])
    end
  end

  action_item :show_rates, only: [:show] do
    link_to 'Show Rates', dialpeer_dialpeer_next_rates_path(resource.id)
  end

  action_item :new_rate, only: [:show] do
    link_to 'New Rate', new_dialpeer_dialpeer_next_rate_path(resource.id)
  end

  action_item :next_rates, only: [:index] do
    link_to 'Next rates', dialpeer_next_rates_path
  end

  index do
    selectable_column
    actions
    id_column

    column :enabled
    column :locked
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
    column :routing_group
    column :routing_tags
    column :priority
    column :force_hit_rate
    column :exclusive_route
    column :initial_interval
    column :initial_rate
    column :next_interval
    column :next_rate
    column :connect_fee
    column :reverse_billing
    column :lcr_rate_multiplier
    column :gateway do |c|
      auto_link(c.gateway, c.gateway.decorated_termination_display_name) unless c.gateway.nil?
    end
    column :gateway_group do |c|
      auto_link(c.gateway_group, c.gateway_group.decorated_display_name) unless c.gateway_group.nil?
    end
    column :vendor do |c|
      auto_link(c.vendor, c.vendor.decorated_vendor_display_name)
    end
    column :account do |c|
      auto_link(c.account, c.account.decorated_vendor_display_name)
    end
    column :routeset_discriminator
    column :valid_from, &:decorated_valid_from
    column :valid_till, &:decorated_valid_till

    column :capacity

    column :calls do |row|
      row.statistic.try(:calls)
    end
    column :total_duration do |row|
      "#{row.statistic.try(:total_duration) || 0} sec."
    end

    column :asr do |row|
      row.statistic.try(:asr)
    end
    column :asr_limit
    column :acd do |row|
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

  filter :id, filters: %i[equals greater_than less_than in_string]
  filter :prefix
  filter :routing_for_contains, as: :string, input_html: { class: 'search_filter_string' }
  filter :enabled, as: :select, collection: [['Yes', true], ['No', false]]
  contractor_filter :vendor_id_eq, label: 'Vendor', path_params: { q: { vendor_eq: true } }
  account_filter :account_id_eq

  filter :routeset_discriminator, input_html: { class: 'chosen' }
  filter :gateway,
         input_html: { class: 'chosen-ajax', 'data-path': '/gateways/search' },
         collection: proc {
           resource_id = params.fetch(:q, {})[:gateway_id_eq]
           resource_id ? Gateway.where(id: resource_id) : []
         }

  filter :gateway_group, input_html: { class: 'chosen' }
  filter :routing_group, input_html: { class: 'chosen' }
  filter :routing_group_routing_plans_id_eq, as: :select, input_html: { class: 'chosen' }, label: 'Routing Plan', collection: -> { Routing::RoutingPlan.all }

  filter :locked, as: :select, collection: [['Yes', true], ['No', false]]
  filter :valid_from, as: :date_time_range
  filter :valid_till, as: :date_time_range
  filter :statistic_calls, as: :numeric
  filter :statistic_total_duration, as: :numeric
  filter :statistic_asr, as: :numeric
  filter :statistic_acd, as: :numeric
  filter :force_hit_rate

  filter :network_prefix_country_id_eq,
         as: :select,
         label: 'Country',
         input_html: { class: 'chosen' },
         collection: -> { System::Country.order(:name) }

  association_ajax_filter :network_prefix_network_id_eq,
                          label: 'Network',
                          scope: -> { System::Network.order(:name) },
                          path: '/system_networks/search'

  filter :network_type_id,
         as: :select,
         label: 'Network Type',
         input_html: { class: 'chosen' },
         collection: -> { System::NetworkType.collection }

  filter :created_at, as: :date_time_range
  filter :external_id
  filter :exclusive_route, as: :select, collection: [['Yes', true], ['No', false]]

  filter :initial_rate
  filter :next_rate
  filter :connect_fee
  filter :scheduler, as: :select, input_html: { class: 'chosen' }

  acts_as_filter_by_routing_tag_ids routing_tag_ids_count: true

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
      f.input :scheduler, as: :select, input_html: { class: 'chosen' }
      f.input :routing_group, input_html: { class: 'chosen' }

      f.input :routing_tag_ids,
              as: :select,
              label: 'Routing tags',
              collection: routing_tag_options,
              multiple: true,
              include_hidden: false,
              input_html: { class: 'chosen' }

      f.input :routing_tag_mode
      f.contractor_input :vendor_id, label: 'Vendor'

      f.account_input :account_id,
                      fill_params: { contractor_id_eq: f.object.vendor_id },
                      fill_required: :contractor_id_eq,
                      input_html: {
                        'data-path-params': { 'q[contractor_id_eq]': '.vendor_id-input' }.to_json,
                        'data-required-param': 'q[contractor_id_eq]'
                      }

      f.input :routeset_discriminator, include_blank: false, input_html: { class: 'chosen' }
      f.input :priority
      f.input :force_hit_rate
      f.input :exclusive_route
      f.input :initial_interval
      f.input :initial_rate
      f.input :next_interval
      f.input :next_rate
      f.input :lcr_rate_multiplier
      f.input :connect_fee
      f.input :reverse_billing

      f.association_ajax_input :gateway_id,
                               label: 'Gateway',
                               scope: Gateway.order(:name),
                               path: '/gateways/search',
                               fill_params: { termination_contractor_id_eq: f.object.vendor_id },
                               input_html: {
                                 'data-path-params': { 'q[termination_contractor_id_eq]': '.vendor_id-input' }.to_json,
                                 'data-required-param': 'q[termination_contractor_id_eq]'
                               }

      f.association_ajax_input :gateway_group_id,
                               label: 'Gateway Group',
                               scope: GatewayGroup.order(:name),
                               path: '/gateway_groups/search',
                               fill_params: { vendor_id_eq: f.object.vendor_id },
                               input_html: {
                                 'data-path-params': { 'q[vendor_id_eq]': '.vendor_id-input' }.to_json,
                                 'data-required-param': 'q[vendor_id_eq]'
                               }

      f.input :valid_from, as: :date_time_picker
      f.input :valid_till, as: :date_time_picker
      f.input :acd_limit
      f.input :asr_limit
      f.input :short_calls_limit
      f.input :capacity
      f.input :src_name_rewrite_rule
      f.input :src_name_rewrite_result
      f.input :src_rewrite_rule
      f.input :src_rewrite_result
      f.input :dst_rewrite_rule
      f.input :dst_rewrite_result
    end
    f.actions
  end

  show do |s|
    tabs do
      tab :general do
        attributes_table do
          row :prefix
          row :dst_number_min_length
          row :dst_number_max_length
          row :country
          row :network
          row :enabled
          row :locked
          row :routing_group
          row :routing_tags
          row :routing_tag_mode
          row :vendor do
            auto_link(s.vendor, s.vendor.decorated_vendor_display_name)
          end
          row :account do
            auto_link(s.account, s.account.decorated_vendor_display_name)
          end
          row :routeset_discriminator
          row :priority
          row :force_hit_rate
          row :exclusive_route
          row :initial_interval
          row :initial_rate
          row :next_interval
          row :next_rate
          row :lcr_rate_multiplier
          row :connect_fee
          row :reverse_billing

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
          column :initial_rate
          column :next_rate
          column :initial_interval
          column :next_interval
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
