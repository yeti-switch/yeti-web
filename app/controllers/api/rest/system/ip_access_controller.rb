# frozen_string_literal: true

require 'prometheus/ip_access_processor'

class Api::Rest::System::IpAccessController < Api::RestController
  include SystemApiAuthorizable

  DEFAULT_CDR_LOOKBACK_DAYS = 7

  def index
    render json: {
      lega_sip_ips: lega_sip_ips,
      lega_rtp_ips: lega_rtp_ips,
      legb_sip_ips: legb_sip_ips,
      legb_sip_fqdns: legb_sip_fqdns,
      legb_rtp_ips: legb_rtp_ips
    }
  end

  private

  def lega_sip_ips
    (customer_auth_addresses + recent_cdr_ips[:lega]).uniq
  end

  def lega_rtp_ips
    gateway_rtp_acl_addresses.uniq
  end

  def legb_sip_ips
    ips_from_hosts = legb_sip_hosts.filter_map { |h| safe_ipaddr(h) }
                                   .map { |ip| "#{ip}/#{ip.cidr_mask}" }
    (ips_from_hosts + recent_cdr_ips[:legb]).uniq
  end

  def legb_sip_fqdns
    legb_sip_hosts.reject { |h| safe_ipaddr(h) }.uniq
  end

  def legb_rtp_ips
    legb_termination_gateways
      .flat_map { |_host, _term_route_set, rtp_acl| Array(rtp_acl) }
      .filter_map { |ip| safe_ipaddr(ip) }
      .map { |ip| "#{ip}/#{ip.cidr_mask}" }
      .uniq
  end

  def legb_sip_hosts
    @legb_sip_hosts ||= begin
      gateway_hosts = legb_termination_gateways.flat_map { |host, route_set, _| collect_hosts(host, route_set) }
      prober_hosts = legb_probers.flat_map { |host, route_set| collect_hosts(host, route_set) }
      registration_hosts = legb_registrations.flat_map { |host, route_set| collect_hosts(host, route_set) }
      (gateway_hosts + prober_hosts + registration_hosts).compact
    end
  end

  def collect_hosts(host, route_set)
    hosts = []
    hosts << extract_host(host) if host.present?
    Array(route_set).each do |uri|
      parsed = SipUriParser.parse(uri)
      hosts << parsed['h'] if parsed && parsed['h'].present?
    end
    hosts
  end

  def legb_termination_gateways
    @legb_termination_gateways ||= Gateway
                                   .where(allow_termination: true)
                                   .pluck(:host, :term_route_set, :rtp_acl)
  end

  def legb_probers
    @legb_probers ||= Equipment::SipOptionsProber.pluck(:ruri_domain, :route_set)
  end

  def legb_registrations
    @legb_registrations ||= Equipment::Registration.pluck(:domain, :route_set)
  end

  # Strips port (and IPv6 brackets) from a Gateway#host value.
  def extract_host(value)
    parsed = SipUriParser.parse("sip:#{value}")
    parsed && parsed['h']
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

  def recent_cdr_ips
    @recent_cdr_ips ||= fetch_recent_cdr_ips
  end

  def fetch_recent_cdr_ips
    return { lega: [], legb: [] } unless clickhouse_enabled?
    return { lega: [], legb: [] } unless cdr_lookback_days.positive?

    response = ClickHouse.connection.execute(recent_cdr_sql)
    body = response.body
    # ClickHouse reports query errors as a non-200 and/or an "exception" field in
    # the (JSON) body (http_write_exception_in_output_format=1).
    if response.status != 200 || (body.is_a?(Hash) && body['exception'])
      detail = body.is_a?(Hash) && body['exception'] ? body['exception'] : body
      Rails.logger.error("Api::Rest::System::IpAccessController: ClickHouse error: HTTP #{response.status}: #{detail}")
      IpAccessProcessor.collect_clickhouse_error_metric if PrometheusConfig.enabled?
      return { lega: [], legb: [] }
    end

    row = Array(body['data']).first
    {
      lega: normalize_cdr_ips(row && row['lega_ips']),
      legb: normalize_cdr_ips(row && row['legb_ips'])
    }
  rescue StandardError => e
    Rails.logger.error("Api::Rest::System::IpAccessController: ClickHouse fetch failed: #{e.class}: #{e.message}")
    IpAccessProcessor.collect_clickhouse_error_metric if PrometheusConfig.enabled?
    { lega: [], legb: [] }
  end

  def normalize_cdr_ips(values)
    Array(values)
      .filter_map { |ip| safe_ipaddr(ip) }
      .map { |ip| "#{ip}/#{ip.cidr_mask}" }
  end

  def recent_cdr_sql
    since = cdr_lookback_days.days.ago.utc.strftime('%Y-%m-%d %H:%M:%S')
    <<~SQL.squish
      SELECT
        groupUniqArrayIf(auth_orig_ip, auth_orig_ip != '') AS lega_ips,
        groupUniqArrayIf(sign_term_ip, sign_term_ip != '') AS legb_ips
      FROM cdrs
      WHERE time_start > '#{since}'
        AND duration > 0
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
