# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class CustomerCreationService
        def initialize(service)
          @service = service
          @service_variables = service.type.variables.merge(service.variables)
          @api_client = PhoneSystemsApiClient.new(@service_variables)
        end

        def create_customer
          payload = {
            data: {
              id: @service.id,
              type: 'customers',
              attributes: @service.variables['attributes']
            }
          }

          response = @api_client.create_customer(payload)
          @api_client.process_response(response, 'create') do |response_body|
            @service.update(id: response_body.dig('data', 'id'))
          end
        end

        def delete_customer
          response = @api_client.delete_customer(@service.id)
          @api_client.process_response(response, 'delete')
        end
      end
    end
  end
end
