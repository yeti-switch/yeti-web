# frozen_string_literal: true

module Mcp
  module Tools
    REGISTRY = {
      'routing.simulate' => RoutingSimulate,
      'cdr.report' => CdrReport
    }.freeze

    def self.list
      REGISTRY.values.map(&:descriptor)
    end

    def self.call(name, args)
      tool = REGISTRY[name]
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
