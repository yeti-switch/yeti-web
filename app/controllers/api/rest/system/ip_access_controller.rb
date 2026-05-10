# frozen_string_literal: true

require 'prometheus/ip_access_processor'

class Api::Rest::System::IpAccessController < Api::RestController
  include SystemApiAuthorizable

  DEFAULT_CDR_LOOKBACK_DAYS = 7

  def index
    render json: addresses
  end

  private

  def addresses
    (customer_auth_addresses + recent_cdr_addresses).uniq
  end

  def customer_auth_addresses
    CustomersAuthNormalized
      .pluck(:ip)
      .uniq
      .filter_map { |ip| safe_ipaddr(ip) }
      .select { |ip| customer_auth_mask_acceptable?(ip) }
      .map { |ip| "#{ip}/#{ip.cidr_mask}" }
  end

  def recent_cdr_addresses
    return [] unless clickhouse_enabled?
    return [] unless cdr_lookback_days.positive?

    response = ClickHouse.connection.execute(recent_cdr_sql)
    body = response.body
    rows = body.is_a?(Hash) ? Array(body['data']) : []
    rows
      .filter_map { |row| safe_ipaddr(row['auth_orig_ip']) }
      .map { |ip| "#{ip}/#{ip.cidr_mask}" }
  rescue StandardError => e
    Rails.logger.error("Api::Rest::System::IpAccessController: ClickHouse fetch failed: #{e.class}: #{e.message}")
    IpAccessProcessor.collect_clickhouse_error_metric if PrometheusConfig.enabled?
    []
  end

  def recent_cdr_sql
    since = cdr_lookback_days.days.ago.utc.strftime('%Y-%m-%d %H:%M:%S')
    <<~SQL.squish
      SELECT DISTINCT auth_orig_ip
      FROM cdrs
      WHERE time_start > '#{since}'
        AND duration > 0
        AND auth_orig_ip != ''
      FORMAT JSON
    SQL
  end

  def customer_auth_mask_acceptable?(ip)
    if ip.ipv4?
      ip.cidr_mask >= min_ipv4_mask
    elsif ip.ipv6?
      ip.cidr_mask >= min_ipv6_mask
    end
  end

  def min_ipv4_mask
    YetiConfig.ip_access&.min_ipv4_mask.to_i
  end

  def min_ipv6_mask
    YetiConfig.ip_access&.min_ipv6_mask.to_i
  end

  def cdr_lookback_days
    YetiConfig.ip_access&.cdr_lookback_days || DEFAULT_CDR_LOOKBACK_DAYS
  end

  def clickhouse_enabled?
    defined?(ClickHouse) && ClickHouse.config&.url.present?
  end

  def safe_ipaddr(str)
    return nil if str.blank?

    IPAddr.new(str.to_s)
  rescue IPAddr::Error
    nil
  end
end
