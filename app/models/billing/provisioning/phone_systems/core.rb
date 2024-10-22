# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class Core
        def initialize(service)
          @service = service
          @service_variables = service.type.variables.merge(service.variables)
          @api_client = PhoneSystemsApiClient.new(@service_variables)
        end

        def provision_services
          CustomerCreationService.new(@service).create_customer
          ConfigurationService.new(@service).configure_services
        end

        def rollback_provision_services
          CustomerCreationService.new(@service).delete_customer
          ConfigurationService.new(@service).delete_configuration
        end

        def self.provision_services(service)
          new(service).provision_services
        end

        def self.rollback_provision_services(service)
          new(service).rollback_provision_services
        end
      end
    end
  end
end
