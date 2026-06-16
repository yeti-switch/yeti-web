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
        'customer_id' => 'customer_id',
        'customer_acc_id' => 'customer_acc_id',
        'customer_auth_id' => 'customer_auth_id',
        'vendor_id' => 'vendor_id',
        'vendor_acc_id' => 'vendor_acc_id',
        'orig_gw_id' => 'orig_gw_id',
        'term_gw_id' => 'term_gw_id',
        'dialpeer_id' => 'dialpeer_id',
        'destination_id' => 'destination_id',
        'routing_group_id' => 'routing_group_id',
        'routing_plan_id' => 'routing_plan_id',
        'rateplan_id' => 'rateplan_id',
        'dst_country_id' => 'dst_country_id',
        'dst_network_id' => 'dst_network_id',
        'src_country_id' => 'src_country_id',
        'src_network_id' => 'src_network_id',
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
        'customer_id' => { col: 'customer_id', type: 'Int32' },
        'customer_acc_id' => { col: 'customer_acc_id', type: 'Int32' },
        'customer_auth_id' => { col: 'customer_auth_id', type: 'Int32' },
        'vendor_id' => { col: 'vendor_id', type: 'Int32' },
        'vendor_acc_id' => { col: 'vendor_acc_id', type: 'Int32' },
        'orig_gw_id' => { col: 'orig_gw_id', type: 'Int32' },
        'term_gw_id' => { col: 'term_gw_id', type: 'Int32' },
        'dialpeer_id' => { col: 'dialpeer_id', type: 'Int32' },
        'destination_id' => { col: 'destination_id', type: 'Int32' },
        'routing_group_id' => { col: 'routing_group_id', type: 'Int32' },
        'routing_plan_id' => { col: 'routing_plan_id', type: 'Int32' },
        'rateplan_id' => { col: 'rateplan_id', type: 'Int32' },
        'dst_country_id' => { col: 'dst_country_id', type: 'Int32' },
        'dst_network_id' => { col: 'dst_network_id', type: 'Int32' },
        'src_country_id' => { col: 'src_country_id', type: 'Int32' },
        'src_network_id' => { col: 'src_network_id', type: 'Int32' },
        'disconnect_initiator_id' => { col: 'disconnect_initiator_id', type: 'Int32' },
        'internal_disconnect_code_id' => { col: 'internal_disconnect_code_id', type: 'Int16' },
        'internal_disconnect_code' => { col: 'internal_disconnect_code', type: 'Int32' },
        'internal_disconnect_reason' => { col: 'internal_disconnect_reason', type: 'String' },
        'lega_disconnect_code' => { col: 'lega_disconnect_code', type: 'Int32' },
        'lega_disconnect_reason' => { col: 'lega_disconnect_reason', type: 'String' },
        'legb_disconnect_code' => { col: 'legb_disconnect_code', type: 'Int32' },
        'legb_disconnect_reason' => { col: 'legb_disconnect_reason', type: 'String' },
        'pop_id' => { col: 'pop_id', type: 'Int32' },
        'node_id' => { col: 'node_id', type: 'Int32' },
        'failed_resource_type_id' => { col: 'failed_resource_type_id', type: 'Int8' },
        'success' => { col: 'success', type: 'Int8' }
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
        'not_in' => { array: true, sql: ->(c, p) { "#{c} NOT IN #{p}" } }
      }.freeze

      def self.descriptor
        {
          name: 'cdr.report',
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
                  field: { type: 'string', enum: (DIMENSIONS.keys + MEASURES.keys) },
                  dir: { type: 'string', enum: %w[asc desc] }
                },
                required: %w[field]
              },
              limit: { type: 'integer', default: DEFAULT_LIMIT, maximum: MAX_LIMIT }
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

          { content: [{ type: 'text', text: JSON.pretty_generate(rows: body['rows'], data: body['data']) }] }
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
        (dimensions.map { |k| "#{DIMENSIONS[k]} AS #{k}" } +
         measures.map { |k| "#{MEASURES[k]} AS #{k}" }).join(', ')
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

        name = next_param
        if op[:array]
          values = f['value']
          # Require an actual non-empty array; don't silently wrap a scalar (the
          # descriptor says in/not_in take an array, and coercing masks mistakes).
          unless values.is_a?(Array) && values.any?
            raise ArgumentError, "operator #{f['op']} needs a non-empty array value"
          end

          @params["param_#{name}"] = values.map { |v| coerce_filter_value(v, spec[:type], f['field']) }
          placeholder = "{#{name}: Array(#{spec[:type]})}"
        else
          value = f['value']
          raise ArgumentError, "operator #{f['op']} needs a scalar value" if value.nil? || value.is_a?(Array)

          @params["param_#{name}"] = coerce_filter_value(value, spec[:type], f['field'])
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
      def coerce_filter_value(value, type, field)
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

      # ORDER BY references a SELECT alias (a constant from our maps), never input
      # text; direction is forced to ASC/DESC. Defaults to first measure desc.
      def order_clause
        ob = @args['order_by']
        return "#{measures.first} DESC" unless ob.is_a?(Hash) && ob['field']

        field = ob['field']
        # Must be a key actually in SELECT (a measure or dimension of THIS query),
        # otherwise ClickHouse raises "Unknown identifier" on the alias.
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
    end
  end
end
