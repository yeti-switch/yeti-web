# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class RouteService
        def initialize(service, response)
          @service = service
          @service_variables = service.type.variables.merge(service.variables.to_h)
          @api_client = PhoneSystemsApiClient.new(@service_variables)
          @pbx_gateway_uuid = response.dig('data', 'id')
        end

        def create_route
          payload = {
            data: {
              type: 'termination_routes',
              attributes: { name: generate_name },
              relationships: {
                gateway: {
                  data: {
                    type: 'termination_gateways',
                    id: @pbx_gateway_uuid
                  }
                },
                customer: {
                  data: {
                    type: 'customers',
                    id: @service.id # Service ID & pbx Customer ID is the same. CustomerCreationService#create_customer.
                  }
                }
              }
            }
          }
          response = @api_client.create_route(payload)
          @api_client.process_response(response, 'create incoming route')
        end

        private

        def generate_name
          "gw-#{@service.uuid}"
        end
      end
    end
  end
end
