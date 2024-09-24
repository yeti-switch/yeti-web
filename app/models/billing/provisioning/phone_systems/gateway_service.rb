# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class GatewayService
        def initialize(service, response)
          @service = service
          @service_variables = service.type.variables.merge(service.variables)
          @api_client = PhoneSystemsApiClient.new(@service_variables)
          @domain = response.dig('data', 'attributes', 'domain')
        end

        def create_gateway
          payload = {
            data: {
              type: 'termination_gateways',
              attributes: @service_variables.fetch('ps_trm_gw', { host: 'sip.yeti-switch.org' }).merge(name: generate_name)
            }
          }
          response = @api_client.create_gateway(payload)
          @api_client.process_response(response, 'create gateway')
        end

        def create_yeti_gateway!
          gateway = Gateway.new
          gateway_attributes = {
            name: "ps-#{@service.id}",
            contractor_id: @service.account.contractor_id,
            enabled: true,
            host: @domain,
            codec_group: CodecGroup.take!
          }
          gateway.assign_attributes(gateway_attributes)
          gateway.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error e.message
          raise Billing::Provisioning::Errors::Error, e.message
        end

        private

        def generate_name
          "gw-#{@service.uuid}"
        end

        def generate_auth_credentials
          # Generate random username/password
        end
      end
    end
  end
end
