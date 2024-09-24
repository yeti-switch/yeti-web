# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class PhoneSystemsApiClient
        NotFoundError = Class.new(Billing::Provisioning::Errors::Error)

        def initialize(service_variables, options = {})
          @debug = options.fetch(:debug, false)
          @api_endpoint = service_variables['endpoint'].chomp('/')
          @api_credentials = {
            username: service_variables['username'],
            password: service_variables['password']
          }
        end

        def create_customer(payload)
          post_request('/api/rest/public/operator/customers', payload)
        end

        def delete_customer(customer_id)
          delete_request("/api/rest/public/operator/customers/#{customer_id}")
        end

        def create_incoming_trunk(payload)
          post_request('/api/rest/public/operator/incoming_trunks', payload)
        end

        def create_gateway(payload)
          post_request('/api/rest/public/operator/termination_gateways', payload)
        end

        def create_route(payload)
          post_request('/api/rest/public/operator/termination_routes', payload)
        end

        def process_response(response, action)
          if response.success?
            Rails.logger.info "#{action} successfully on telecom.center"
            # In case of delete request there is 204 response with empty (nil) response, let's handle this case.
            response_body = begin
                              JSON.parse(response.body)
                            rescue TypeError => _e
                              nil
                            end

            if block_given?
              yield response_body
            end

            response_body
          elsif response.code == 404
            error_message = retrieve_validation_error(response)
            Rails.logger.error error_message
            raise NotFoundError, error_message
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
        rescue TypeError, JSON::ParserError => _e
          'Unknown error'
        end

        private

        def post_request(path, payload)
          HTTParty.post(
            "#{@api_endpoint}#{path}",
            body: payload.to_json,
            basic_auth: @api_credentials,
            headers: { 'Content-Type' => 'application/vnd.api+json' },
            debug_output: @debug ? $stdout : false
          )
        end

        def delete_request(path)
          HTTParty.delete(
            "#{@api_endpoint}#{path}",
            basic_auth: @api_credentials,
            headers: { 'Content-Type' => 'application/vnd.api+json' },
            debug_output: @debug ? $stdout : false
          )
        end
      end
    end
  end
end
