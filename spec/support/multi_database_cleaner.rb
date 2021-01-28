# frozen_string_literal: true

require 'database_cleaner/active_record/truncation'

module MultiDatabaseCleaner
  EXCEPT_TABLES = [
    # 'invoice_periods',
    # 'codec_groups',
    # 'codecs',
    # 'codec_group_codecs',
    # 'destination_rate_policy',
    # 'disconnect_code_namespace',
    # 'disconnect_code',
    # 'disconnect_initiators',
    # 'diversion_policy',
    # 'dtmf_receive_modes',
    # 'dtmf_send_modes',
    # 'dump_level',
    # 'filter_types',
    # 'gateway_rel100_modes',
    # 'numberlist_actions',
    # 'numberlist_modes',
    # 'rate_profit_control_modes',
    # 'routing_groups',
    # 'sdp_c_location',
    # 'session_refresh_methods',
    # 'sortings',
    # 'transport_protocols',
    # 'tag_actions',
    # 'routing_tag_modes',
    # 'gateway_inband_dtmf_filtering_modes',
    # 'routeset_discriminators',
    # 'gateway_media_encryption_modes',
    # 'gateway_network_protocol_priorities',
    # 'gateway_group_balancing_modes',
    # 'customers_auth_src_number_fields',
    # 'customers_auth_src_name_fields',
    # 'customers_auth_dst_number_fields',
    # 'alerts',
    # 'resource_action',
    # 'resource_type',
    # 'switch_interface_in',
    # 'switch_interface_out',
    # 'countries',
    # 'api_log_config',
    # 'guiconfig',
    # 'jobs',
    # 'network_types',
    # 'networks',
    # 'network_prefixes',
    # 'sensor_levels',
    # 'sensor_modes',
    # 'sip_schemas',
    # 'timezones'
  ].freeze

  CDR_EXCEPT_TABLES = %w[
    invoice_states
    invoice_types
    cdr_interval_report_aggregator
    scheduler_periods
    call_duration_round_modes
    amount_round_modes
    config
  ].freeze

  module_function

  def clean_with(strategy)
    DatabaseCleaner.clean_with *strategy_args(strategy)
    SecondBase.on_base do
      DatabaseCleaner.clean_with *cdr_strategy_args(strategy)
    end
  end

  def strategy=(strategy)
    DatabaseCleaner.strategy = strategy_for(strategy)
    SecondBase.on_base do
      DatabaseCleaner.strategy = cdr_strategy_for(strategy)
    end
  end

  def start
    DatabaseCleaner.start
    SecondBase.on_base do
      DatabaseCleaner.start
    end
  end

  def clean
    DatabaseCleaner.clean
    SecondBase.on_base do
      DatabaseCleaner.clean
    end
  end

  def strategy_args(strategy)
    return [strategy] if strategy != :truncation

    [strategy, except: EXCEPT_TABLES]
  end

  def cdr_strategy_args(strategy)
    return [strategy] if strategy != :truncation

    [strategy, except: CDR_EXCEPT_TABLES]
  end

  def strategy_for(strategy)
    return strategy if strategy != :truncation

    DatabaseCleaner::ActiveRecord::Truncation.new(except: EXCEPT_TABLES)
  end

  def cdr_strategy_for(strategy)
    return strategy if strategy != :truncation

    DatabaseCleaner::ActiveRecord::Truncation.new(except: CDR_EXCEPT_TABLES)
  end
end
