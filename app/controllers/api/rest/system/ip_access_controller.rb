# frozen_string_literal: true

require 'prometheus/ip_access_processor'

class Api::Rest::System::IpAccessController < Api::RestController
  include SystemApiAuthorizable

  DEFAULT_CDR_LOOKBACK_DAYS = 7

  def index
    render json: {
      lega_sip_ips: lega_sip_ips,
      lega_rtp_ips: lega_rtp_ips
    }
  end

  private

  def lega_sip_ips
    (customer_auth_addresses + recent_cdr_addresses).uniq
  end

  def lega_rtp_ips
    gateway_rtp_acl_addresses.uniq
  end

  def customer_auth_addresses
    CustomersAuthNormalized
      .distinct
      .where(
        '(family(ip) = 4 AND masklen(ip) >= ?) OR (family(ip) = 6 AND masklen(ip) >= ?)',
        lega_sip_min_ipv4_mask, lega_sip_min_ipv6_mask
      )
      .pluck(:ip)
      .filter_map { |ip| safe_ipaddr(ip) }
      .map { |ip| "#{ip}/#{ip.cidr_mask}" }
  end

  def gateway_rtp_acl_addresses
    sql = <<~SQL.squish
      SELECT DISTINCT ip_elem
      FROM #{Gateway.quoted_table_name} g
      CROSS JOIN unnest(g.rtp_acl) AS ip_elem
      WHERE g.id IN (SELECT gateway_id FROM #{CustomersAuth.quoted_table_name})
        AND (
          (family(ip_elem) = 4 AND masklen(ip_elem) >= ?) OR
          (family(ip_elem) = 6 AND masklen(ip_elem) >= ?)
        )
    SQL
    query = ActiveRecord::Base.sanitize_sql_array([sql, lega_rtp_min_ipv4_mask, lega_rtp_min_ipv6_mask])
    Gateway.connection.select_values(query)
      .filter_map { |ip| safe_ipaddr(ip) }
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

  def lega_sip_min_ipv4_mask
    YetiConfig.ip_access&.lega_sip_min_ipv4_mask.to_i
  end

  def lega_sip_min_ipv6_mask
    YetiConfig.ip_access&.lega_sip_min_ipv6_mask.to_i
  end

  def lega_rtp_min_ipv4_mask
    YetiConfig.ip_access&.lega_rtp_min_ipv4_mask.to_i
  end

  def lega_rtp_min_ipv6_mask
    YetiConfig.ip_access&.lega_rtp_min_ipv6_mask.to_i
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
