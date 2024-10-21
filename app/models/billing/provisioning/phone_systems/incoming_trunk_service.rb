# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class IncomingTrunkService
        def initialize(service)
          @service = service
          @service_variables = service.type.variables.merge(service.variables)
          @api_client = PhoneSystemsApiClient.new(@service_variables)
        end

        def create_trunk
          payload = {
            data: {
              type: 'incoming_trunks',
              attributes: @service_variables.fetch('ps_incoming_trunk', {}).merge(name: generate_name),
              relationships: {
                customer: {
                  data: {
                    type: 'customers',
                    id: @service.id # Service ID & pbx Customer ID is the same. CustomerCreationService#create_customer.
                  }
                }
              }
            }
          }
          response = @api_client.create_incoming_trunk(payload)
          @api_client.process_response(response, 'create incoming trunk')
        end

        private

        def generate_name
          "gw-#{@service.uuid}"
        end
      end
    end
  end
end
