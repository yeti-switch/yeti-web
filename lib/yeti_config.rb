# frozen_string_literal: true

require_relative 'base_config'

class YetiConfig < BaseConfig
  setting :site_title
  setting :site_title_image

  setting :api do
    setting :token_lifetime, type: :integer
  end

  setting :cdr_export do
    setting :dir_path
    setting :delete_url
  end

  setting :role_policy do
    setting :when_no_config, values: %w[allow disallow raise]
    setting :when_no_policy_class, values: %w[allow disallow raise]
  end

  setting :partition_remove_delay,
          type: :hash,
          keys: %w[cdr.cdr auth_log.auth_log rtp_statistics.streams logs.api_requests],
          value_type: :integer

  setting :prometheus do
    setting :enabled, type: :boolean
    setting :host
    setting :port
    setting :default_labels, type: :hash
  end

  setting :sentry do
    setting :enabled, type: :boolean
    setting :dsn
    setting :node_name
    setting :environment
  end
end
