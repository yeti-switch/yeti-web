# frozen_string_literal: true

module ActiveCalls
  class CreateOriginationGatewayStats < ApplicationService
    parameter :calls, required: true
    parameter :current_time, required: true

    def call
      attrs_list = build_calls_attrs_list
      missing_gateway_ids = Gateway.where.not(id: calls.keys).pluck(:id)
      attrs_list.concat build_empty_attrs_list(missing_gateway_ids)
      return if attrs_list.empty?

      Stats::ActiveCallOrigGateway.insert_all!(attrs_list)
    end

    private

    def build_calls_attrs_list
      calls.map do |gateway_id, sub_calls|
        {
          count: sub_calls.count,
          created_at: current_time,
          gateway_id: gateway_id
        }
      end
    end

    def build_empty_attrs_list(gateway_ids)
      gateway_ids.map do |gateway_id|
        {
          count: 0,
          created_at: current_time,
          gateway_id: gateway_id
        }
      end
    end
  end
end
