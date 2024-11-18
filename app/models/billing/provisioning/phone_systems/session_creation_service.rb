# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class SessionCreationService
        def initialize(service)
          @service = service
          @service_variables = service.type.variables.merge(service.variables)
          @api_client = PhoneSystemsApiClient.new(@service_variables)
        end

        def self.call!(service)
          new(service).call!
        end

        def call!
          url = ''
          payload = {
            data: {
              type: 'sessions',
              relationships: {
                customer: {
                  data: {
                    type: 'customers',
                    id: @service.id
                  }
                }
              }
            }
          }

          response = @api_client.create_session(payload)
          @api_client.process_response(response, 'created the "Customer sessions" on the phone.systems server') do |response_body|
            url = response_body.dig('data', 'attributes', 'uri')
          end

          url
        end
      end
    end
  end
end
