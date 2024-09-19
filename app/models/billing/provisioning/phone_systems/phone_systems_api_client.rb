# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class PhoneSystemsApiClient
        def initialize(service_variables)
          @debug = service_variables.fetch(:debug, true)
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
