# frozen_string_literal: true

module Mcp
  module Tools
    REGISTRY = {
      'routing_simulate' => RoutingSimulate,
      'cdr_report' => CdrReport
    }.freeze

    # `mcp.tools` in yeti_web.yml, when set, is an allowlist of tool names; unset
    # exposes every tool. Applies to tools/call as well as tools/list, so a tool
    # left out is not callable by name either.
    def self.registry
      allowed = YetiConfig.mcp&.tools
      return REGISTRY if allowed.nil?

      allowed = Array(allowed).map(&:to_s)
      unknown = allowed - REGISTRY.keys
      Rails.logger.warn("[MCP] yeti_web.yml mcp.tools lists unknown tools: #{unknown.join(', ')}") if unknown.any?

      REGISTRY.slice(*allowed)
    end

    def self.list
      registry.values.map(&:descriptor)
    end

    def self.call(name, args)
      tool = registry[name]
      return tool_error("Unknown tool: #{name.inspect}") unless tool

      tool.call(args)
    rescue StandardError => e
      Rails.logger.error("[MCP] tool=#{name} error=#{e.class}: #{e.message}\n#{e.backtrace.first(10).join("\n")}")
      tool_error("#{e.class}: #{e.message}")
    end

    def self.tool_error(message)
      { isError: true, content: [{ type: 'text', text: message }] }
    end
  end
end
