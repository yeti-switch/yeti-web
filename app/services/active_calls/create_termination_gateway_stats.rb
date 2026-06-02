# frozen_string_literal: true

module ActiveCalls
  class CreateTerminationGatewayStats < ApplicationService
    parameter :calls, required: true
    parameter :current_time, required: true

    def call
      attrs_list = build_calls_attrs_list
      return if attrs_list.empty?

      Stats::ActiveCallTermGateway.insert_all!(attrs_list)
    end

    private

    # Only gateways with active calls are stored. Absence of a row for a given
    # snapshot means zero — the chart reconstructs the zero baseline client-side.
    def build_calls_attrs_list
      calls.map do |gateway_id, sub_calls|
        {
          count: sub_calls.count,
          created_at: current_time,
          gateway_id: gateway_id
        }
      end
    end
  end
end
