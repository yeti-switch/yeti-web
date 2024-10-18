# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class RouteService
        def initialize(service, response)
          @service = service
          @service_variables = service.type.variables.merge(service.variables.to_h)
          @api_client = PhoneSystemsApiClient.new(@service_variables)
          @gateway_uuid = response.dig('data', 'id')
        end

        def create_route
          payload = {
            data: {
              type: 'termination_routes',
              attributes: { name: generate_name },
              relationships: {
                gateway: {
                  data: {
                    type: 'gateways',
                    id: @gateway_uuid
                  }
                },
                customer: {
                  data: {
                    type: 'customers',
                    id: @service.id
                  }
                }
              }
            }
          }
          response = @api_client.create_route(payload)
          @api_client.process_response(response, 'create route')
        end

        private

        def generate_name
          "gw-#{@service.uuid}"
        end
      end
    end
  end
end
