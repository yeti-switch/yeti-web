# frozen_string_literal: true

module Billing
  module Provisioning
    class Base
      class << self
        # @param service_type [Billing::ServiceType]
        # @raise [Billing::Provisioning::Errors::InvalidVariablesError]
        # @return [Hash,nil] verified service_type variables
        def verify_service_type_variables!(service_type)
          service_type.variables
        end
      end

      attr_reader :service
      delegate :account, to: :service

      # @param service [Billing::Service]
      def initialize(service)
        @service = service
      end

      # @raise [Billing::Provisioning::Errors::InvalidVariablesError]
      # @return [Hash,nil] verified service variables
      def verify_service_variables!
        service.variables
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

      # Called before destroying the service and before destroying dependant package_counters
      # To prevent service destruction:
      #   service.errors.add(:base, ...)
      #   throw(:abort)
      #
      def before_destroy
        nil
      end

      # Called after destroying the service but before transaction COMMIT
      def after_destroy
        nil
      end
    end
  end
end
