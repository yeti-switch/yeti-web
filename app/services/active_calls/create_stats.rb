# frozen_string_literal: true

module ActiveCalls
  class CreateStats < ApplicationService
    parameter :calls, required: true
    parameter :current_time, required: true

    def call
      attrs_list = build_calls_attrs_list
      missing_node_ids = Node.where.not(id: calls.keys).pluck(:id)
      attrs_list.concat build_empty_attrs_list(missing_node_ids)
      return if attrs_list.empty?

      Stats::ActiveCall.insert_all!(attrs_list)
    end

    private

    def build_calls_attrs_list
      calls.map do |node_id, sub_calls|
        {
          count: sub_calls.count,
          created_at: current_time,
          node_id: node_id
        }
      end
    end

    def build_empty_attrs_list(node_ids)
      node_ids.map do |node_id|
        {
          count: 0,
          created_at: current_time,
          node_id: node_id
        }
      end
    end
  end
end
