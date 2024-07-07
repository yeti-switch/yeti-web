# frozen_string_literal: true

module Billing
  module Provisioning
    class Base
      attr_reader :service
      delegate :account, to: :service

      # @param service [Billing::Service]
      def initialize(service)
        @service = service
      end

      def after_create
        nil
      end

      # Called before renewing the service
      def before_renew
        nil
      end

      # Called after renewing the service
      def after_renew
        nil
      end

      # Called after successful renew
      def after_success_renew
        nil
      end

      # Called after failed renew (when the service became suspended)
      def after_failed_renew
        nil
      end
    end
  end
end
