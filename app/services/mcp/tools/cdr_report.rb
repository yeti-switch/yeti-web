# frozen_string_literal: true

module Mcp
  module Tools
    # Aggregated, read-only reporting over the ClickHouse `cdrs` table, for
    # traffic analysis and anomaly detection.
    #
    # SQL-injection safe by construction: the LLM never supplies SQL text. It
    # picks dimensions, measures, filter fields and operators by NAME (keys into
    # the allowlist maps below, which map to server-defined SQL fragments), and
    # supplies only VALUES (bound as ClickHouse query parameters — {name:Type}
    # placeholders + a `param_name` entry). An unknown key fails the map lookup
    # and is rejected; no LLM-provided string ever reaches the query text.
    #
    # Three field roles, kept in separate maps so a column is only reachable in
    # the ways it's allowed:
    #   DIMENSIONS - group-by / select axes (bounded reference IDs, codes,
    #                user-agent, Q.850 text/params, GeoIP lat/lon, time buckets).
    #   FILTERS    - WHERE conditions (same bounded fields; value bound as param).
    #   MEASURES   - aggregates only. Raw number/IP/name columns appear ONLY inside
    #                uniq() measures, so their *cardinality* is exposed but never
    #                their values, and they are absent from DIMENSIONS/FILTERS so
    #                there's no value-probing WHERE oracle either.
    #   DICTIONARIES - post-query id => display-name resolution, REFERENCE DATA
    #                ONLY. Counterparty identity and prefix-valued references are
    #                never resolved; see DICTIONARIES.
    #
    # Run this tool's ClickHouse user as read-only, scoped to the cdrs table;
    # per-query caps are also added in a SETTINGS clause as defense in depth.
    class CdrReport
      # Unqualified: the database is supplied by the connection (config.database
      # from click_house.yml), same as the other ClickhouseReport queries.
      TABLE = 'cdrs'

      DEFAULT_LIMIT = 200
      MAX_LIMIT = 2000
      MAX_WINDOW_DAYS = 31
      MAX_EXECUTION_TIME = 120 # seconds

      # name => SQL fragment (constant; the LLM only sends the name)
      DIMENSIONS = {
        # Contractor, account and gateway references are reachable only as uuids.
        'customer_uuid' => 'customer_id',
        'vendor_uuid' => 'vendor_id',
        'customer_acc_uuid' => 'customer_acc_id',
        'vendor_acc_uuid' => 'vendor_acc_id',
        'orig_gw_uuid' => 'orig_gw_id',
        'term_gw_uuid' => 'term_gw_id',
        'dialpeer_id' => 'dialpeer_id',
        'destination_id' => 'destination_id',
        'routing_group_id' => 'routing_group_id',
        'routing_plan_id' => 'routing_plan_id',
        'rateplan_id' => 'rateplan_id',
        'dst_country_id' => 'dst_country_id',
        'dst_network_id' => 'dst_network_id',
        'src_country_id' => 'src_country_id',
        'src_network_id' => 'src_network_id',
        'dst_network_type_id' => 'dst_network_type_id',
        'src_network_type_id' => 'src_network_type_id',
        'disconnect_initiator_id' => 'disconnect_initiator_id',
        'internal_disconnect_code_id' => 'internal_disconnect_code_id',
        'internal_disconnect_code' => 'internal_disconnect_code',
        'internal_disconnect_reason' => 'internal_disconnect_reason',
        'lega_disconnect_code' => 'lega_disconnect_code',
        'lega_disconnect_reason' => 'lega_disconnect_reason',
        'legb_disconnect_code' => 'legb_disconnect_code',
        'legb_disconnect_reason' => 'legb_disconnect_reason',
        'lega_q850_cause' => 'lega_q850_cause',
        'legb_q850_cause' => 'legb_q850_cause',
        'lega_q850_text' => 'lega_q850_text',
        'legb_q850_text' => 'legb_q850_text',
        'lega_q850_params' => 'lega_q850_params',
        'legb_q850_params' => 'legb_q850_params',
        'lega_user_agent' => 'lega_user_agent',
        'legb_user_agent' => 'legb_user_agent',
        'pop_id' => 'pop_id',
        'node_id' => 'node_id',
        'failed_resource_type_id' => 'failed_resource_type_id',
        'sign_orig_transport_protocol_id' => 'sign_orig_transport_protocol_id',
        'sign_term_transport_protocol_id' => 'sign_term_transport_protocol_id',
        'auth_orig_transport_protocol_id' => 'auth_orig_transport_protocol_id',
        'success' => 'success',
        'is_last_cdr' => 'is_last_cdr',
        'routing_attempt' => 'routing_attempt',
        # GeoIP origin (IP-derived city/ISP centroid — discrete, low-cardinality).
        'origin_lat' => 'auth_orig_lat',
        'origin_lon' => 'auth_orig_lon',
        # Time buckets.
        'minute' => 'toStartOfMinute(time_start)',
        'hour' => 'toStartOfHour(time_start)',
        'day' => 'toDate(time_start)'
      }.freeze

      # name => SQL aggregate fragment (constant). distinct_* expose only the
      # COUNT of distinct raw values, never the values themselves.
      MEASURES = {
        'calls' => 'count()',
        'answered' => 'countIf(success = 1)',
        'failed' => 'countIf(success = 0)',
        'asr' => 'round(countIf(success = 1) / nullIf(count(), 0), 4)',
        'acd' => 'round(sumIf(duration, success = 1) / nullIf(countIf(success = 1), 0), 1)',
        'total_duration' => 'sum(duration)',
        'avg_duration' => 'round(avg(duration), 1)',
        'avg_pdd' => 'round(avg(pdd), 3)',
        'avg_rtt' => 'round(avg(rtt), 3)',
        'avg_routing_delay' => 'round(avg(routing_delay), 3)',
        # PDD/RTT conditioned on a positive sample so unset values don't drag
        # the quantile to 0; acd_* is duration over answered calls.
        'pdd_p50' => 'round(quantileIf(0.5)(pdd, pdd > 0), 3)',
        'pdd_p95' => 'round(quantileIf(0.95)(pdd, pdd > 0), 3)',
        'pdd_p99' => 'round(quantileIf(0.99)(pdd, pdd > 0), 3)',
        'rtt_p50' => 'round(quantileIf(0.5)(rtt, rtt > 0), 3)',
        'rtt_p95' => 'round(quantileIf(0.95)(rtt, rtt > 0), 3)',
        'rtt_p99' => 'round(quantileIf(0.99)(rtt, rtt > 0), 3)',
        'acd_p50' => 'round(quantileIf(0.5)(duration, success = 1), 1)',
        'acd_p95' => 'round(quantileIf(0.95)(duration, success = 1), 1)',
        'acd_p99' => 'round(quantileIf(0.99)(duration, success = 1), 1)',
        'short_calls' => 'countIf(success = 1 AND duration <= {short_call_seconds: UInt16})',
        'short_calls_ratio' => 'round(countIf(success = 1 AND duration <= {short_call_seconds: UInt16}) / ' \
                               'nullIf(countIf(success = 1), 0), 4)',
        'revenue' => 'round(sum(customer_price), 4)',
        'cost' => 'round(sum(vendor_price), 4)',
        'profit' => 'round(sum(profit), 4)',
        # cardinality-only measures over otherwise-restricted columns
        'distinct_src_numbers' => 'uniq(src_prefix_in)',
        'distinct_dst_numbers' => 'uniq(dst_prefix_in)',
        'distinct_orig_ips' => 'uniq(sign_orig_ip)',
        'distinct_auth_ips' => 'uniq(auth_orig_ip)',
        'distinct_cli_names' => 'uniq(src_name_in)'
      }.freeze

      # name => { col:, type: } for WHERE conditions. Deliberately excludes the
      # raw number/IP/name columns (those are uniq-measure inputs only).
      FILTERS = {
        'customer_uuid' => { col: 'customer_id', type: 'Int32', uuid: 'Contractor' },
        'vendor_uuid' => { col: 'vendor_id', type: 'Int32', uuid: 'Contractor' },
        'customer_acc_uuid' => { col: 'customer_acc_id', type: 'Int32', uuid: 'Account' },
        'vendor_acc_uuid' => { col: 'vendor_acc_id', type: 'Int32', uuid: 'Account' },
        'orig_gw_uuid' => { col: 'orig_gw_id', type: 'Int32', uuid: 'Gateway' },
        'term_gw_uuid' => { col: 'term_gw_id', type: 'Int32', uuid: 'Gateway' },
        'dialpeer_id' => { col: 'dialpeer_id', type: 'Int32' },
        'destination_id' => { col: 'destination_id', type: 'Int32' },
        'routing_group_id' => { col: 'routing_group_id', type: 'Int32' },
        'routing_plan_id' => { col: 'routing_plan_id', type: 'Int32' },
        'rateplan_id' => { col: 'rateplan_id', type: 'Int32' },
        'dst_country_id' => { col: 'dst_country_id', type: 'Int32' },
        'dst_network_id' => { col: 'dst_network_id', type: 'Int32' },
        'src_country_id' => { col: 'src_country_id', type: 'Int32' },
        'src_network_id' => { col: 'src_network_id', type: 'Int32' },
        'dst_network_type_id' => { col: 'dst_network_type_id', type: 'Int16' },
        'src_network_type_id' => { col: 'src_network_type_id', type: 'Int16' },
        'disconnect_initiator_id' => { col: 'disconnect_initiator_id', type: 'Int32' },
        'internal_disconnect_code_id' => { col: 'internal_disconnect_code_id', type: 'Int16' },
        'internal_disconnect_code' => { col: 'internal_disconnect_code', type: 'Int32' },
        'internal_disconnect_reason' => { col: 'internal_disconnect_reason', type: 'String' },
        'lega_disconnect_code' => { col: 'lega_disconnect_code', type: 'Int32' },
        'lega_disconnect_reason' => { col: 'lega_disconnect_reason', type: 'String' },
        'legb_disconnect_code' => { col: 'legb_disconnect_code', type: 'Int32' },
        'legb_disconnect_reason' => { col: 'legb_disconnect_reason', type: 'String' },
        'lega_user_agent' => { col: 'lega_user_agent', type: 'String' },
        'legb_user_agent' => { col: 'legb_user_agent', type: 'String' },
        'pop_id' => { col: 'pop_id', type: 'Int32' },
        'node_id' => { col: 'node_id', type: 'Int32' },
        'failed_resource_type_id' => { col: 'failed_resource_type_id', type: 'Int8' },
        'success' => { col: 'success', type: 'Int8' },
        'is_last_cdr' => { col: 'is_last_cdr', type: 'Int8' },
        'routing_attempt' => { col: 'routing_attempt', type: 'Int32' }
      }.freeze

      # op => { array:, sql: builder(column, placeholder) }. `array` ops bind an
      # Array(Type) param.
      OPS = {
        'eq' => { array: false, sql: ->(c, p) { "#{c} = #{p}" } },
        'not_eq' => { array: false, sql: ->(c, p) { "#{c} != #{p}" } },
        'gt' => { array: false, sql: ->(c, p) { "#{c} > #{p}" } },
        'gte' => { array: false, sql: ->(c, p) { "#{c} >= #{p}" } },
        'lt' => { array: false, sql: ->(c, p) { "#{c} < #{p}" } },
        'lte' => { array: false, sql: ->(c, p) { "#{c} <= #{p}" } },
        'in' => { array: true, sql: ->(c, p) { "#{c} IN #{p}" } },
        'not_in' => { array: true, sql: ->(c, p) { "#{c} NOT IN #{p}" } },
        # `text_only` rejects these on numeric columns.
        'contains' => {
          array: false, text_only: true,
          sql: ->(c, p) { "positionCaseInsensitive(#{c}, #{p}) > 0" }
        },
        'not_contains' => {
          array: false, text_only: true,
          sql: ->(c, p) { "positionCaseInsensitive(#{c}, #{p}) = 0" }
        }
      }.freeze

      # An allowlist: adding a key here is what discloses a name. Two classes
      # must stay out — counterparty identity (customer, vendor, account,
      # gateway, rateplan) and prefix-valued references
      # (destination, dialpeer), whose display value is a phone number.
      DICTIONARIES = {
        'dst_country_id' => { model: 'System::Country' },
        'src_country_id' => { model: 'System::Country' },
        'dst_network_id' => { model: 'System::Network' },
        'src_network_id' => { model: 'System::Network' },
        'dst_network_type_id' => { model: 'System::NetworkType' },
        'src_network_type_id' => { model: 'System::NetworkType' },
        'routing_group_id' => { model: 'Routing::RoutingGroup' },
        'routing_plan_id' => { model: 'Routing::RoutingPlan' },
        'pop_id' => { model: 'Pop' },
        'node_id' => { model: 'Node' },
        'sign_orig_transport_protocol_id' => { model: 'Equipment::TransportProtocol' },
        'sign_term_transport_protocol_id' => { model: 'Equipment::TransportProtocol' },
        'auth_orig_transport_protocol_id' => { model: 'Equipment::TransportProtocol' },
        'disconnect_initiator_id' => { static: -> { Cdr::Cdr::DISCONNECT_INITIATORS } }
      }.freeze

      # Selected as an id, returned as the referenced record's uuid.
      UUID_DIMENSIONS = {
        'customer_uuid' => 'Contractor',
        'vendor_uuid' => 'Contractor',
        'customer_acc_uuid' => 'Account',
        'vendor_acc_uuid' => 'Account',
        'orig_gw_uuid' => 'Gateway',
        'term_gw_uuid' => 'Gateway'
      }.freeze

      # Measures whose SQL carries the {short_call_seconds} placeholder.
      SHORT_CALL_MEASURES = %w[short_calls short_calls_ratio].freeze
      SHORT_CALL_DEFAULT_SECONDS = 6
      SHORT_CALL_MAX_SECONDS = 300

      def self.descriptor
        {
          name: 'cdr_report',
          description: <<~DESC.strip,
            Aggregated, read-only report over CDRs (ClickHouse cdrs table) for
            traffic analysis and anomaly detection. Choose `measures` (aggregates)
            and optional `dimensions` (group-by axes) by name, optional `filters`,
            and a mandatory time window (`from`/`to`, max #{MAX_WINDOW_DAYS} days).
            Returns one row per dimension combination with the requested measures.

            The distinct_* measures reveal fraud/anomaly patterns without exposing
            any actual numbers/IPs/names: e.g. high `calls` with
            `distinct_src_numbers` = 1 means every call shares a single CLI;
            `distinct_orig_ips` spiking on an account suggests credential sharing.

            Reference dimensions are returned with their display name alongside
            the id (dst_country_id => dst_country_name, dst_network_id =>
            dst_network_name, dst_network_type_id => dst_network_type_name, and
            likewise for routing group/plan, pop, node, transport protocol and
            disconnect initiator). Set `resolve_names` to false to skip it.

            Contractors, accounts and gateways appear ONLY as uuids -
            `customer_uuid`, `vendor_uuid`, `customer_acc_uuid`,
            `vendor_acc_uuid`, `orig_gw_uuid`, `term_gw_uuid`. There is no
            customer_id, customer_acc_id or term_gw_id dimension or filter. To
            narrow to one, pass its uuid: {field: "customer_uuid", op: "eq", value:
            "9f8a2c14-6b3e-4d71-b2a0-8c5e1f04a933"}. A bare numeric id is
            rejected. Uuids are stable, so you can correlate the same contractor
            account or gateway across reports, but they carry no ordering or count
            information - do not try to derive one, and do not guess which real
            company a uuid is.

            The remaining counterparty dimension - rateplan - is returned as a
            bare id and has no name form; this tool does not disclose who a
            trading partner is. destination_id and
            dialpeer_id are likewise unresolved (their value is a dial prefix).
            Report all of these as-is and let the reader resolve them in the
            admin UI.

            Distribution measures: `pdd_p50/p95/p99`, `rtt_p50/p95/p99` (both
            over samples with a positive value) and `acd_p50/p95/p99` (call
            duration over ANSWERED calls - the percentile form of `acd`). Prefer
            these over the avg_* measures when a few outliers can skew the mean.

            `short_calls` / `short_calls_ratio` count answered calls no longer
            than `short_call_seconds` (default #{SHORT_CALL_DEFAULT_SECONDS}s),
            as a share of answered calls - a high ratio on a route suggests FAS
            or early teardown rather than genuine short conversations.

            The `contains` / `not_contains` operators do a case-insensitive
            substring match and apply to text fields only (user agents,
            disconnect reasons) - e.g. filter lega_user_agent contains
            "Asterisk" to segment traffic by the customer's platform.

            Coded value semantics:
            - `success`: 0 = failed/unanswered, 1 = answered.
            - `is_last_cdr`: 1 = final CDR of a call leg, 0 = an intermediate
              rerouting attempt. Filter `is_last_cdr = 1` to count real calls
              (otherwise reroute attempts inflate the counts).
            - `disconnect_initiator_id`: #{Cdr::Cdr::DISCONNECT_INITIATORS.map { |id, name| "#{id} = #{name}" }.join(', ')}.
            For disconnect detail prefer the human-readable `*_disconnect_reason`
            dimensions over the numeric `*_disconnect_code` fields.
          DESC
          inputSchema: {
            type: 'object',
            properties: {
              measures: {
                type: 'array', minItems: 1,
                items: { type: 'string', enum: MEASURES.keys },
                description: 'Aggregates to compute (at least one).'
              },
              dimensions: {
                type: 'array',
                items: { type: 'string', enum: DIMENSIONS.keys },
                description: 'Group-by axes. Omit for a single grand-total row.'
              },
              filters: {
                type: 'array',
                items: {
                  type: 'object',
                  properties: {
                    field: { type: 'string', enum: FILTERS.keys },
                    op: { type: 'string', enum: OPS.keys },
                    value: { description: 'Scalar for eq/gt/…; array for in/not_in.' }
                  },
                  required: %w[field op value]
                },
                description: 'Optional WHERE conditions, ANDed together.'
              },
              from: { type: 'string', description: 'Window start, UTC, e.g. "2026-06-13 10:00:00".' },
              to: { type: 'string', description: 'Window end (exclusive), UTC.' },
              order_by: {
                type: 'object',
                properties: {
                  field: { type: 'string', enum: (DIMENSIONS.keys - UUID_DIMENSIONS.keys + MEASURES.keys) },
                  dir: { type: 'string', enum: %w[asc desc] }
                },
                required: %w[field]
              },
              limit: { type: 'integer', default: DEFAULT_LIMIT, maximum: MAX_LIMIT },
              short_call_seconds: {
                type: 'integer',
                default: SHORT_CALL_DEFAULT_SECONDS,
                maximum: SHORT_CALL_MAX_SECONDS,
                description: 'Duration threshold (seconds) for the short_calls / ' \
                             'short_calls_ratio measures.'
              },
              resolve_names: {
                type: 'boolean',
                default: true,
                description: 'Append a `*_name` column for the reference dimensions ' \
                             '(country, network, network type, routing group/plan, pop, ' \
                             'node, transport protocol, disconnect initiator). Set false ' \
                             'for id-only output.'
              }
            },
            required: %w[measures from to]
          }
        }
      end

      def self.call(args)
        new(args).run
      rescue ArgumentError => e
        Mcp::Tools.tool_error("Invalid input: #{e.message}")
      end

      def initialize(args)
        @args = args || {}
        @params = {}
        @param_seq = 0
      end

      def run
        # build_sql raises ArgumentError for bad input — that surfaces as a
        # helpful "Invalid input" via .call (it's about the request, not server
        # internals), so keep it OUTSIDE the rescue below.
        sql = build_sql
        Rails.logger.debug { "[MCP] cdr.report sql=#{sql} params=#{@params}" }

        begin
          response = ClickHouse.connection.execute(sql, nil, params: @params)
          body = response.body
          # ClickHouse renders query errors as a non-200 and/or an "exception"
          # field in the (JSON) body (http_write_exception_in_output_format=1).
          if response.status != 200 || (body.is_a?(Hash) && body['exception'])
            detail = body.is_a?(Hash) && body['exception'] ? body['exception'] : body
            return log_and_fail(sql, "ClickHouse responded HTTP #{response.status}: #{detail}")
          end

          data = present_rows(body['data'])
          { content: [{ type: 'text', text: JSON.pretty_generate(rows: body['rows'], data: data) }] }
        rescue StandardError => e
          log_and_fail(sql, "#{e.class}: #{e.message}", e)
        end
      end

      private

      # Log the real cause (HTTP status/body or exception) to the yeti-web log,
      # and return a generic error to the client — never expose the SQL or any
      # ClickHouse internals.
      def log_and_fail(sql, detail, exception = nil)
        lines = ["[MCP] cdr.report failed: #{detail}", "  sql: #{sql}", "  params: #{@params}"]
        lines.concat(exception.backtrace.first(10)) if exception&.backtrace
        Rails.logger.error(lines.join("\n"))
        Mcp::Tools.tool_error('Internal server error')
      end

      # Assembles the statement from individually-validated clause builders. Every
      # clause emits ONLY allowlist-mapped constants and {param:Type} placeholders;
      # caller-supplied values live in @params, never in the SQL text. Each builder
      # is a small, independently unit-testable method (see the unit spec).
      def build_sql
        [
          "SELECT #{select_clause}",
          "FROM #{TABLE}",
          "WHERE #{where_clause}",
          group_by_clause,
          "ORDER BY #{order_clause}",
          "LIMIT #{limit}",
          settings_clause,
          # JSON output so the gem parses the body to a Hash (rows/data); without
          # it ClickHouse defaults to TabSeparated and run would break. FORMAT must
          # be the final clause (after SETTINGS).
          'FORMAT JSON'
        ].reject(&:empty?).join(' ')
      end

      # Validated, memoized key lists. Raise on any key not in the allowlists, so
      # an unknown/injected name can never reach the SQL.
      def measures
        @measures ||= begin
          keys = fetch_keys(@args['measures'], MEASURES, 'measure')
          raise ArgumentError, 'at least one measure is required' if keys.empty?

          keys
        end
      end

      def dimensions
        @dimensions ||= fetch_keys(@args['dimensions'], DIMENSIONS, 'dimension')
      end

      # SELECT: dimension + measure fragments (constants), each aliased to its key.
      def select_clause
        @params['param_short_call_seconds'] = short_call_seconds if measures.intersect?(SHORT_CALL_MEASURES)

        (dimensions.map { |k| "#{DIMENSIONS[k]} AS #{k}" } +
         measures.map { |k| "#{MEASURES[k]} AS #{k}" }).join(', ')
      end

      def short_call_seconds
        n = Integer(@args['short_call_seconds'] || SHORT_CALL_DEFAULT_SECONDS)
        n.clamp(1, SHORT_CALL_MAX_SECONDS)
      rescue ArgumentError, TypeError
        raise ArgumentError, 'short_call_seconds must be an integer'
      end

      # GROUP BY the dimension fragments (constants); empty string when no
      # dimensions (single grand-total row) so build_sql drops the clause.
      def group_by_clause
        return '' if dimensions.empty?

        "GROUP BY #{dimensions.map { |k| DIMENSIONS[k] }.join(', ')}"
      end

      # Per-query wall-clock cap (the row count is already bounded by LIMIT).
      def settings_clause
        "SETTINGS max_execution_time = #{MAX_EXECUTION_TIME}"
      end

      def where_clause
        conds = [time_window]
        Array(@args['filters']).each { |f| conds << filter_condition(f) }
        conds.join(' AND ')
      end

      # time_start is the partition + leading sort key, so this range is the cheap
      # access path. Mandatory and length-capped to bound cost.
      def time_window
        from = parse_time(@args['from'], 'from')
        to = parse_time(@args['to'], 'to')
        raise ArgumentError, '`from` must be before `to`' unless from < to
        raise ArgumentError, "window exceeds #{MAX_WINDOW_DAYS} days" if to - from > MAX_WINDOW_DAYS * 86_400

        @params['param_from'] = from.utc.strftime('%Y-%m-%d %H:%M:%S')
        @params['param_to'] = to.utc.strftime('%Y-%m-%d %H:%M:%S')
        # Parse the bound strings explicitly as UTC so the window is interpreted
        # as UTC regardless of the ClickHouse server/column timezone (DateTime is
        # stored as a UTC instant; only literal parsing/display is tz-dependent).
        "time_start >= toDateTime({from: String}, 'UTC') AND " \
          "time_start < toDateTime({to: String}, 'UTC')"
      end

      def filter_condition(f)
        raise ArgumentError, 'each filter must be an object' unless f.is_a?(Hash)

        spec = FILTERS[f['field']] or raise ArgumentError, "unknown filter field #{f['field'].inspect}"
        op = OPS[f['op']] or raise ArgumentError, "unknown operator #{f['op'].inspect}"

        if op[:text_only] && spec[:type] != 'String'
          raise ArgumentError, "operator #{f['op']} applies to text fields only, not #{f['field']}"
        end

        name = next_param
        if op[:array]
          values = f['value']
          # Require an actual non-empty array; don't silently wrap a scalar (the
          # descriptor says in/not_in take an array, and coercing masks mistakes).
          unless values.is_a?(Array) && values.any?
            raise ArgumentError, "operator #{f['op']} needs a non-empty array value"
          end

          coerced = values.map { |v| coerce_filter_value(v, spec, f['field']) }
          @params["param_#{name}"] = format_array_param(coerced, spec[:type])
          placeholder = "{#{name}: Array(#{spec[:type]})}"
        else
          value = f['value']
          raise ArgumentError, "operator #{f['op']} needs a scalar value" if value.nil? || value.is_a?(Array)

          @params["param_#{name}"] = coerce_filter_value(value, spec, f['field'])
          placeholder = "{#{name}: #{spec[:type]}}"
        end
        op[:sql].call(spec[:col], placeholder)
      end

      # Coerce a filter value to its column type before binding. For integer
      # columns ClickHouse's parameter binder rejects anything that isn't a bare
      # integer (e.g. `success = true` → "Value true cannot be parsed as Int8"),
      # so map booleans to 0/1 and accept integer-ish values, rejecting the rest as
      # invalid input (clear client error rather than a server-side CH failure).
      # Non-integer columns (e.g. String reason filters) bind their value as-is.
      def coerce_filter_value(value, spec, field)
        return coerce_uuid(value, field, spec[:uuid]) if spec[:uuid]

        type = spec[:type]
        return value unless type.start_with?('Int', 'UInt')

        case value
        when true then 1
        when false then 0
        when Integer then value
        when String
          Integer(value, exception: false) ||
            (raise ArgumentError, "filter #{field}: #{value.inspect} is not a valid #{type}")
        else
          raise ArgumentError, "filter #{field}: #{value.inspect} is not a valid #{type}"
        end
      end

      # A bare integer must be rejected, or the filter becomes an enumeration
      # oracle. An unknown uuid binds an id nothing matches rather than raising,
      # so the filter does not answer "does this contractor exist?" either.
      def coerce_uuid(value, field, model)
        unless value.to_s.strip.match?(UuidLookup::UUID_FORMAT)
          raise ArgumentError, "filter #{field}: expected a uuid, got #{value.inspect}"
        end

        model.constantize.id_by_uuid(value) || 0
      end

      # ORDER BY references a SELECT alias (a constant from our maps), never input
      # text; direction is forced to ASC/DESC. Defaults to first measure desc.
      def order_clause
        ob = @args['order_by']
        return "#{measures.first} DESC" unless ob.is_a?(Hash) && ob['field']

        field = ob['field']
        # Must be a key actually in SELECT (a measure or dimension of THIS query),
        # otherwise ClickHouse raises "Unknown identifier" on the alias.
        # Sorting by a uuid sorts by the id it hides.
        if UUID_DIMENSIONS.key?(field)
          raise ArgumentError, "order_by field #{field.inspect} is not sortable; order by a measure instead"
        end

        unless (measures + dimensions).include?(field)
          raise ArgumentError, "order_by field #{field.inspect} must be one of the selected measures or dimensions"
        end

        dir = ob['dir'].to_s.casecmp('asc').zero? ? 'ASC' : 'DESC'
        "#{field} #{dir}"
      end

      def limit
        n = Integer(@args['limit'] || DEFAULT_LIMIT)
        n.clamp(1, MAX_LIMIT)
      rescue ArgumentError, TypeError
        raise ArgumentError, 'limit must be an integer'
      end

      def fetch_keys(list, map, label)
        Array(list).map do |k|
          raise ArgumentError, "unknown #{label} #{k.inspect}" unless map.key?(k)

          k
        end
      end

      # Parse `from`/`to` as UTC, independent of the app's Time.zone. Combined
      # with toDateTime(..., 'UTC') in the WHERE clause, the window is interpreted
      # as UTC regardless of the ClickHouse server/column timezone.
      def parse_time(value, label)
        raise ArgumentError, "`#{label}` is required" if value.nil? || value.to_s.strip.empty?

        t = begin
          Time.find_zone!('UTC').parse(value.to_s)
            rescue ArgumentError
              nil
        end
        t || raise(ArgumentError, "invalid #{label} time: #{value.inspect}")
      end

      def next_param
        @param_seq += 1
        "f#{@param_seq}"
      end

      # ClickHouse HTTP params are scalar strings, so an Array(T) must be sent
      # as its literal — "[1,7]" / "['a','b']". A Ruby Array encodes as repeated
      # `param_x[]=` keys, which ClickHouse cannot parse.
      def format_array_param(values, type)
        "[#{values.map { |v| quote_array_element(v, type) }.join(',')}]"
      end

      def quote_array_element(value, type)
        return value.to_s if type.start_with?('Int', 'UInt', 'Float')

        "'#{value.to_s.gsub(/[\\']/) { |m| "\\#{m}" }}'"
      end

      def present_rows(data)
        return data if data.blank?

        resolve_names(replace_ids_with_uuids(data))
      end

      # In place: the raw id must not survive into the response.
      # One lookup per referenced model, not per dimension.
      def replace_ids_with_uuids(data)
        keys = dimensions & UUID_DIMENSIONS.keys
        return data if keys.empty?

        uuids = {}
        keys.group_by { |key| UUID_DIMENSIONS[key] }.each do |model, group|
          ids = data.flat_map { |row| group.map { |key| reference_id(row[key]) } }.compact.uniq
          uuids[model] = ids.empty? ? {} : model.constantize.where(id: ids).pluck(:id, :uuid).to_h
        end

        data.each do |row|
          keys.each { |key| row[key] = uuids[UUID_DIMENSIONS[key]][reference_id(row[key])] }
        end
      end

      # ClickHouse renders 64-bit ints as quoted strings, so accept both forms.
      def reference_id(value)
        return value if value.is_a?(Integer) && value.positive?

        id = Integer(value.to_s, 10, exception: false)
        id if id&.positive?
      end

      # Best-effort: a reference lookup failing must not lose the report.
      def resolve_names(data)
        return data if data.blank? || @args['resolve_names'] == false

        dicts = dimensions & DICTIONARIES.keys
        return data if dicts.empty?

        lookups = dicts.index_with { |dim| dictionary_for(dim, data) }
        data.map { |row| row_with_names(row, lookups) }
      rescue StandardError => e
        Rails.logger.error("[MCP] cdr.report name resolution failed: #{e.class}: #{e.message}")
        data
      end

      # Each name sits directly after the id it explains.
      def row_with_names(row, lookups)
        row.each_with_object({}) do |(key, value), out|
          out[key] = value
          next unless lookups.key?(key)

          out["#{key.delete_suffix('_id')}_name"] = value.nil? ? nil : lookups[key][value]
        end
      end

      def dictionary_for(dim, data)
        spec = DICTIONARIES[dim]
        return spec[:static].call if spec[:static]

        ids = data.filter_map { |row| row[dim] }.uniq
        return {} if ids.empty?

        spec[:model].constantize.where(id: ids).pluck(:id, :name).to_h
      end
    end
  end
end
