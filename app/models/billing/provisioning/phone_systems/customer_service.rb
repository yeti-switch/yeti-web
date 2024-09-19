# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class CustomerService
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
              attributes: @service_variables['attributes']
            }
          }

          response = @api_client.create_customer(payload)
          process_response(response, 'create') do |response_body|
            @service.update(id: response_body.dig('data', 'id'))
          end
        end

        def delete_customer
          response = @api_client.delete_customer(@service.id)
          process_response(response, 'delete')
        end

        def self.delete_customer(service)
          new(service).delete_customer
        end

        def self.create_customer(service)
          new(service).create_customer
        end

        private

        def process_response(response, action)
          if response.success?
            Rails.logger.info "Customer #{action}d successfully on telecom.center"
            yield JSON.parse(response.body) if block_given?
          else
            handle_error(response)
          end
        end

        def handle_error(response)
          error_message = retrieve_validation_error(response)
          Rails.logger.error error_message
          raise Billing::Provisioning::Errors::Error, error_message
        end

        def retrieve_validation_error(response)
          response_body = JSON.parse(response.body)
          response_body.dig('errors', 0, 'detail')
        rescue StandardError
          'Unknown error'
        end
      end
    end
  end
end
