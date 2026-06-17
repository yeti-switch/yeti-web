# frozen_string_literal: true

module Mcp
  module Tools
    # Wraps Routing::SimulationForm (which calls switch22.route_debug /
    # switch22.route_release) and formats the resulting candidate list into
    # MCP-friendly JSON. Read-only — route_debug runs inside a transaction
    # that doesn't persist anything.
    class RoutingSimulate
      DEFAULTS = {
        remote_port: 5060,
        pop_id: 1,
        transport_protocol_id: 1,
        interface: 'input'
      }.freeze

      def self.descriptor
        {
          name: 'routing_simulate',
          description: <<~DESC.strip,
            Simulate how a call would be routed without actually placing it.
            Returns the ordered list of route candidates with the dialpeer,
            vendor, termination gateway, rateplan, routing plan/group, and
            destination match for each. NOTICE lines from the routing SP are
            returned in `notices` — useful for diagnosing why a candidate
            was rejected. Wraps switch22.route_debug.
          DESC
          inputSchema: {
            type: 'object',
            properties: {
              src_number: { type: 'string', description: 'Calling party number (e.g. +442012345678)' },
              dst_number: { type: 'string', description: 'Called party number (e.g. +14155551234)' },
              auth_id: { type: 'integer', description: 'Optional CustomersAuth.id. If omitted, the routing engine resolves auth from remote_ip / x_yeti_auth as a real SIP request would.' },
              remote_ip: { type: 'string', description: 'SIP remote IP — required because the routing engine uses it for IP-based auth resolution when auth_id is omitted' },
              remote_port: { type: 'integer', default: DEFAULTS[:remote_port] },
              pop_id: { type: 'integer', default: DEFAULTS[:pop_id] },
              transport_protocol_id: { type: 'integer', default: DEFAULTS[:transport_protocol_id] },
              interface: { type: 'string', default: DEFAULTS[:interface] },
              release_mode: {
                type: 'boolean',
                default: false,
                description: 'false → route_debug (no side effects); true → route_release (production-like)'
              }
            },
            required: %w[src_number dst_number remote_ip]
          }
        }
      end

      def self.call(args)
        form = Routing::SimulationForm.new(
          src_number: args['src_number'],
          dst_number: args['dst_number'],
          auth_id: args['auth_id'],
          remote_ip: args['remote_ip'],
          remote_port: (args['remote_port'] || DEFAULTS[:remote_port]).to_s,
          pop_id: (args['pop_id'] || DEFAULTS[:pop_id]).to_s,
          transport_protocol_id: (args['transport_protocol_id'] || DEFAULTS[:transport_protocol_id]).to_s,
          interface: args['interface'] || DEFAULTS[:interface],
          release_mode: args['release_mode'] ? '1' : '0'
        )

        unless form.save
          return Mcp::Tools.tool_error("Invalid input: #{form.errors.full_messages.join('; ')}")
        end

        body = {
          candidates: (form.debug || []).each_with_index.map { |r, i| serialize_candidate(r, i + 1) },
          notices: form.notices
        }
        { content: [{ type: 'text', text: JSON.pretty_generate(body) }] }
      end

      def self.serialize_candidate(r, rank)
        {
          rank: rank,
          customer: ref(r.customer, :name),
          customer_auth: ref(r.customer_auth, :name),
          destination: r.destination && { id: r.destination.id, prefix: r.destination.prefix },
          dialpeer: r.dialpeer && {
            id: r.dialpeer.id,
            prefix: r.dialpeer.prefix,
            vendor: r.dialpeer.vendor&.name,
            priority: r.dialpeer.priority
          },
          termination_gateway: ref(r.termination_gateway, :name),
          rateplan: ref(r.rateplan, :name),
          routing_plan: ref(r.routing_plan, :name),
          routing_group: ref(r.routing_group, :name),
          dst_network: r.dst_network&.name,
          dst_country: r.dst_country&.name,
          disconnect_code: r.disconnect_code && {
            id: r.disconnect_code.id,
            code: r.disconnect_code.code,
            reason: r.disconnect_code.reason
          }
        }.compact
      end

      def self.ref(obj, label_method)
        return nil unless obj

        { id: obj.id, name: obj.public_send(label_method) }
      end
    end
  end
end
