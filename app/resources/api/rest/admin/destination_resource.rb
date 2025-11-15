# frozen_string_literal: true

class Api::Rest::Admin::DestinationResource < ::BaseResource
  model_name 'Routing::Destination'

  attributes :enabled, :next_rate, :connect_fee, :initial_interval, :next_interval, :dp_margin_fixed,
             :dp_margin_percent, :initial_rate, :asr_limit, :acd_limit, :short_calls_limit,
             :prefix, :reject_calls, :use_dp_intervals, :valid_from, :valid_till, :external_id,
             :routing_tag_ids, :dst_number_min_length, :dst_number_max_length, :reverse_billing,
             :profit_control_mode_id, :rate_policy_id, :routing_tag_mode_id

  paginator :paged

  has_one :rate_group, class_name: 'RateGroup'
  has_one :country, class_name: 'Country', foreign_key_on: :related
  has_one :network, class_name: 'Network', foreign_key_on: :related
  has_many :destination_next_rates, class_name: 'DestinationNextRate'

  filters :external_id, :prefix, :rate_group_id

  ransack_filter :enabled, type: :boolean
  ransack_filter :prefix, type: :string
  ransack_filter :next_rate, type: :number
  ransack_filter :connect_fee, type: :number
  ransack_filter :initial_interval, type: :number
  ransack_filter :next_interval, type: :number
  ransack_filter :dp_margin_fixed, type: :number
  ransack_filter :dp_margin_percent, type: :number
  ransack_filter :initial_rate, type: :number
  ransack_filter :reject_calls, type: :boolean
  ransack_filter :use_dp_intervals, type: :boolean
  ransack_filter :valid_from, type: :datetime
  ransack_filter :valid_till, type: :datetime
  ransack_filter :external_id, type: :number
  ransack_filter :asr_limit, type: :number
  ransack_filter :acd_limit, type: :number
  ransack_filter :short_calls_limit, type: :number
  ransack_filter :quality_alarm, type: :boolean
  ransack_filter :uuid, type: :uuid
  ransack_filter :dst_number_min_length, type: :number
  ransack_filter :dst_number_max_length, type: :number
  ransack_filter :reverse_billing, type: :boolean
  ransack_filter :profit_control_mode_id, type: :number
  ransack_filter :rate_policy_id, type: :number
  ransack_filter :routing_tag_mode_id, type: :number

  filter :rateplan_id_eq, apply: lambda { |records, values, _options|
    records.ransack(rateplan_id_filter: values).result
  }
  filter :country_id_eq, apply: lambda { |records, values, _options|
    records.ransack(country_id_filter: values).result
  }

  def self.updatable_fields(_context)
    %i[
      enabled
      prefix
      rate_group
      next_rate
      connect_fee
      initial_interval
      next_interval
      dp_margin_fixed
      dp_margin_percent
      rate_policy_id
      initial_rate
      reverse_billing
      reject_calls
      use_dp_intervals
      valid_from
      valid_till
      profit_control_mode_id
      routing_tag_mode_id
      external_id
      asr_limit
      acd_limit
      short_calls_limit
      routing_tag_ids
      dst_number_min_length
      dst_number_max_length
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end

  def self.sortable_fields(_context = nil)
    super + %i[country.name network.name network_type.sorting_priority]
  end

  # related to issue https://github.com/cerebris/jsonapi-resources/issues/1409
  def self.sort_records(records, order_options, context = {})
    local_records = records
    custom_sort_fields = %w[country.name network.name network_type.sorting_priority]

    order_options.each_pair do |field, direction|
      case field.to_s
      when 'country.name'
        local_records = local_records.left_joins(:country).order("countries.name #{direction}")
        order_options.delete('country.name')
      when 'network.name'
        local_records = local_records.left_joins(:network).order("networks.name #{direction}")
        order_options.delete('network.name')
      when 'network_type.sorting_priority'
        type_sorting = System::NetworkType.order(sorting_priority: direction).pluck(:id)
        local_records = local_records.left_joins(:network).in_order_of(:'networks.type_id', type_sorting)
        order_options.delete('network_type.sorting_priority')
      else
        local_records = apply_sort(local_records, order_options.except(*custom_sort_fields), context)
      end
    end

    local_records
  end
end
