# frozen_string_literal: true

require 'config'

Config.class_eval do
  def self.setting_files(config_root, _env)
    [
      File.join(config_root, 'yeti_web.yml').to_s
    ].freeze
  end
end

Config.setup do |setup_config|
  setup_config.const_name = 'YetiConfig'
  setup_config.use_env = false

  # Validate presence and type of specific config values.
  # Check https://github.com/dry-rb/dry-validation for details.
  setup_config.schema do
    # config.validate_keys = true

    required(:site_title).filled(:string)
    required(:site_title_image).filled(:string)

    required(:calls_monitoring).schema do
      required(:write_account_stats).value(:bool?)
      required(:write_gateway_stats).value(:bool?)
      required(:teardown_on_disabled_customer_auth).value(:bool?)
      required(:teardown_on_disabled_term_gw).value(:bool?)
      required(:teardown_on_disabled_orig_gw).value(:bool?)
    end

    required(:api).schema do
      required(:token_lifetime).maybe(:int?)
    end

    optional(:rec_format).value(Dry::Types['string'].enum('wav', 'mp3'))

    optional(:routing_simulation_default_interface).filled(:string)

    required(:cdr_export).schema do
      required(:dir_path).filled(:string)
      required(:delete_url).filled(:string)
    end

    required(:role_policy).schema do
      required(:when_no_config).value(Dry::Types['string'].enum('allow', 'disallow', 'raise'))
      required(:when_no_policy_class).value(Dry::Types['string'].enum('allow', 'disallow', 'raise'))
    end

    required(:partition_remove_delay).hash do
      required(:'cdr.cdr').maybe(:string, format?: /\A\d+ days\z/)
      required(:'auth_log.auth_log').maybe(:string, format?: /\A\d+ days\z/)
      required(:'rtp_statistics.rx_streams').maybe(:string, format?: /\A\d+ days\z/)
      required(:'rtp_statistics.tx_streams').maybe(:string, format?: /\A\d+ days\z/)
      required(:'logs.api_requests').maybe(:string, format?: /\A\d+ days\z/)
    end

    optional(:partition_detach_before_drop).filled(:bool)

    required(:prometheus).schema do
      required(:enabled).value(:bool?)
      required(:host).maybe(:string)
      required(:port).maybe(:int?)
      optional(:default_labels).hash
    end

    required(:sentry).schema do
      required(:enabled).value(:bool?)
      required(:dsn).maybe(:string)
      required(:node_name).filled(:string)
      required(:environment).filled(:string)
    end

    optional(:telemetry).schema do
      optional(:enabled).filled(:bool)
    end

    required(:versioning_disable_for_models).each(:string)

    optional(:keep_expired_destinations_days)
    optional(:keep_expired_dialpeers_days)
    optional(:keep_balance_notifications_days)

    optional(:cryptomus).schema do
      optional(:api_key).maybe(:string)
      optional(:merchant_id).maybe(:string)
      optional(:url_callback).maybe(:string)
      optional(:url_return).maybe(:string)
    end

    optional(:customer_api_cdr_hide_fields).array(:string)
  end
end

Config.evaluate_erb_in_yaml = true
begin
  Config.load_and_set_settings(Config.setting_files(::Rails.root.join('config'), ::Rails.env))
rescue Config::Validation::Error => e
  warn e.message
  exit 1 # rubocop:disable Rails/Exit
end

require 'system_info_configs'
require 'custom_struct'

system_info_path = Rails.root.join('config/system_info.yml')
SystemInfoConfigs.load_file(system_info_path) if File.exist?(system_info_path)
