# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems < Base
      def verify_service_variables!
        contract = ServiceVariablesContract.new
        result = contract.call(service.variables)
        raise Billing::Provisioning::Errors::InvalidVariablesError, result.errors.to_h unless result.success?

        service.variables
      end

      def after_create
        CustomerService.create_customer(service)
      end

      def before_destroy
        CustomerService.delete_customer(service)
      end

      def self.verify_service_type_variables!(service_type)
        contract = ServiceTypeVariablesContract.new
        result = contract.call(service_type.variables)
        raise Billing::Provisioning::Errors::InvalidVariablesError, result.errors.to_h unless result.success?

        service_type.variables
      end
    end
  end
end
