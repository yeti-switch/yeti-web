# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class ConfigurationService
        def initialize(service)
          @service = service
          @service_variables = service.type.variables.merge(service.variables)
          @api_client = PhoneSystemsApiClient.new(@service_variables)
        end

        def configure_services
          response = configure_incoming_trunk
          response = configure_gateway(response)
          configure_route(response)
        end

        def delete_configurations

        end

        private

        def configure_incoming_trunk
          IncomingTrunkService.new(@service).create_trunk
        end

        def configure_gateway(response)
          gws = GatewayService.new(@service, response)
          response_from_pbx = gws.create_gateway
          gws.create_yeti_gateway!

          response_from_pbx
        end

        def configure_route(response)
          RouteService.new(@service, response).create_route
        end
      end
    end
  end
end
