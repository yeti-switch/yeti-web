# frozen_string_literal: true

module Yeti
  module RpcCalls
    class IncomingRegistrations < ::Yeti::RpcCalls::Base
      fetch_type :first_success
      parameter :auth_id

      private

      def process_node(node)
        data = node.incoming_registrations(auth_id: auth_id.presence, empty_on_error: false)
        data.map(&:symbolize_keys)
      end
    end
  end
end
