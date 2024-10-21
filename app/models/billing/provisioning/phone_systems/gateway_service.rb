# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class GatewayService
        def initialize(service, response = {})
          @service = service
          @service_variables = service.type.variables.merge(service.variables)
          @api_client = PhoneSystemsApiClient.new(@service_variables)
          @domain = response.dig('data', 'attributes', 'domain')
        end

        def create_remote_gateway
          payload = {
            data: {
              type: 'termination_gateways',
              attributes: @service_variables.fetch('ps_trm_gw', default_attributes).merge(name: phone_systems_gateway_name),
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
          response = @api_client.create_gateway(payload)
          @api_client.process_response(response, 'create gateway')
        end

        def default_attributes
          { host: 'sip.yeti-switch.org', authorization_name: generate_auth_username, authorization_password: generate_auth_password }
        end

        def create_yeti_gateway!
          gateway = Gateway.new
          gateway_attributes = {
            name: yeti_gateway_name,
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

        def delete_yeti_gateway
          Gateway.delete_by(name: yeti_gateway_name)
        end

        def self.delete_yeti_gateway(service)
          new(service).delete_yeti_gateway
        end

        private

        def yeti_gateway_name
          "ps-#{@service.id}"
        end

        def phone_systems_gateway_name
          "gw-#{@service.uuid}"
        end

        def generate_auth_username
          SecureRandom.alphanumeric(20)
        end

        def generate_auth_password
          SecureRandom.alphanumeric(20)
        end
      end
    end
  end
end
