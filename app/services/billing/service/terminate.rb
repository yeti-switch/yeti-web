# frozen_string_literal: true

module Billing
  class Service
    class Terminate < ApplicationService
      parameter :record, required: true

      Error = Class.new(StandardError)

      def call
        raise_if_invalid!

        record.transaction do
          record.update!(state_id: Billing::Service::STATE_ID_TERMINATED)
        end
      rescue ActiveRecord::RecordNotSaved => e
        raise Error, e.message
      end

      private

      def raise_if_invalid!
        raise Error, 'Service is already terminated.' if record.terminated?
      end
    end
  end
end
