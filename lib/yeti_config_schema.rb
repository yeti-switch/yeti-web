# frozen_string_literal: true

require 'dry-validation'

# Validation schema for config/yeti_web.yml. Lives here rather than in the Rails initializer so
# that YetiConfigLoader can apply it for every process reading YetiConfig, Rails or not.
# See https://github.com/dry-rb/dry-validation for the DSL.
module YetiConfigSchema
  # SemanticLogger::Levels::LEVELS, spelled out rather than required: this file is loaded
  # by every reader of YetiConfig, including the ones that never log through it.
  LOG_LEVELS = %w[trace debug info warn error fatal].freeze

  module_function

  # @param setup_config [Config::Options] the object yielded by Config.setup
  def apply(setup_config)
    setup_config.schema do
      # config.validate_keys = true

      required(:site_title).filled(:string)
      required(:site_title_image).filled(:string)

      required(:calls_monitoring).schema do
        required(:write_account_stats).value(:bool?)
        required(:write_gateway_stats).value(:bool?)
        optional(:teardown_on_disabled_customer_auth).value(:bool?)
        optional(:teardown_on_disabled_term_gw).value(:bool?)
        optional(:teardown_on_disabled_orig_gw).value(:bool?)
      end

      required(:api).schema do
        required(:token_lifetime).maybe(:int?)
        optional(:customer).schema do
          required(:token_lifetime).maybe(:int?)
          optional(:call_jwt_lifetime).maybe(:int?)
          optional(:call_jwt_secret).maybe(:string)
          optional(:outgoing_cdr_hide_fields).array(:string)
          optional(:outgoing_statistics_use_customer_duration).value(:bool?)
          optional(:incoming_cdr_hide_fields).array(:string)
          optional(:incoming_statistics_use_vendor_duration).value(:bool?)
        end
        optional(:system).schema do
          optional(:token).maybe(:string)
        end
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

      optional(:disable_balance_notification_emails).filled(:bool)

      required(:prometheus).schema do
        required(:enabled).value(:bool?)
        required(:host).maybe(:string)
        required(:port).maybe(:int?)
        optional(:default_labels).hash
      end

      # Logging, see YetiLogSetup. One block per appender. An appender without a level of
      # its own follows the global one (config.log_level, RAILS_LOG_LEVEL).
      optional(:logging).schema do
        optional(:stdout).schema do
          optional(:level).maybe(:string, included_in?: YetiConfigSchema::LOG_LEVELS)
        end

        # A blank `url` disables the appender. `tags` are the static fields added to
        # every record it ships. `max_queue_size` is either -1, for a queue that grows
        # without a limit, or the records to hold before they start being dropped.
        optional(:elasticsearch).schema do
          optional(:level).maybe(:string, included_in?: YetiConfigSchema::LOG_LEVELS)
          optional(:url).maybe(:string)
          optional(:index).maybe(:string)
          optional(:tags).hash
          optional(:transport_options).hash
          optional(:batch_size).maybe(:integer, gt?: 0)
          optional(:batch_seconds).maybe(:integer, gt?: 0)
          optional(:max_queue_size).maybe(:integer, gteq?: -1, excluded_from?: [0])
        end
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

      # Mounts the Doorkeeper OAuth provider (/oauth/authorize, /oauth/token,
      # /oauth/register, /.well-known/oauth-authorization-server). Independent
      # of MCP — can be enabled on its own to power SSO for other clients.
      # Block AND `enabled` key are both optional; missing → treated as false.
      optional(:oauth).schema do
        optional(:enabled).value(:bool?)
        optional(:issuer).maybe(:string)

        optional(:oidc).schema do
          optional(:enabled).value(:bool?)
          optional(:signing_key_path).maybe(:string)
        end
      end

      # Mounts /api/mcp. Requires oauth.enabled (MCP authenticates via OAuth
      # bearer tokens); if oauth.enabled is false this flag has no effect.
      # Block AND `enabled` key are both optional; missing → treated as false.
      optional(:mcp).schema do
        optional(:enabled).value(:bool?)
      end

      required(:versioning_disable_for_models).each(:string)

      optional(:keep_expired_destinations_days)
      optional(:keep_expired_dialpeers_days)
      optional(:keep_balance_notifications_days)

      optional(:cryptomus).schema do
        optional(:api_key).maybe(:string)
        optional(:merchant_id).maybe(:string)
        optional(:base_url).maybe(:string)
        optional(:url_callback).maybe(:string)
        optional(:url_return).maybe(:string)
      end

      optional(:invoice).schema do
        optional(:auto_approve).value(:bool)
        optional(:pdf_converter).maybe(:string)
        # External yeti-pdf render service. When configured (and a template has
        # html_template) invoice PDFs are produced via yeti-pdf instead of the
        # legacy ODT + pdf_converter path.
        optional(:pdf_api).schema do
          required(:base_url).filled(:string)
          optional(:auth_token).maybe(:string)
          optional(:timeout).maybe(:integer)
          optional(:http_proxy).maybe(:string)
          optional(:use_env_proxy).maybe(:bool?)
        end
      end
      optional(:admin_ui).schema do
        optional(:session_lifetime).maybe(:int?)
        optional(:per_page).array(:integer)
      end

      optional(:ip_access).schema do
        optional(:cdr_lookback_days).maybe(:int?)
        optional(:lega_sip_min_ipv4_mask).maybe(:int?)
        optional(:lega_sip_min_ipv6_mask).maybe(:int?)
        optional(:lega_rtp_min_ipv4_mask).maybe(:int?)
        optional(:lega_rtp_min_ipv6_mask).maybe(:int?)
      end
    end
  end
end
