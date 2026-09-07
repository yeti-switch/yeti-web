# frozen_string_literal: true

module Billing
  module Provisioning
    class PhoneSystems
      class GatewayService
        AUTH_CREDENTIAL_LENGTH = 20

        def initialize(service, response = {})
          @service = service
          @service_variables = service.type.variables.merge(service.variables.to_h)
          @api_client = PhoneSystemsApiClient.new(@service_variables)
          @domain = response.dig('data', 'attributes', 'domain')
        end

        # Returns nil when ps_trm_gw is not configured - the customer then gets an
        # inbound-only setup and there is nothing for the termination route to point at.
        def create_remote_gateway
          return if ps_trm_gw.blank?

          payload = {
            data: {
              type: 'termination_gateways',
              attributes: remote_gateway_attributes,
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

        def create_yeti_gateway!
          gateway = Gateway.new
          gateway_attributes = {
            name: yeti_gateway_name,
            contractor_id: @service.account.contractor_id,
            enabled: true,
            host: @domain,
            codec_group: CodecGroup.take!
          }
          # The PBX authenticates on Yeti with the credentials provisioned into its
          # termination gateway, so both sides have to carry the very same pair. Without
          # ps_trm_gw there is no such gateway, so the incoming auth stays empty.
          if ps_trm_gw.present?
            gateway_attributes[:incoming_auth_username] = authorization_name
            gateway_attributes[:incoming_auth_password] = authorization_password
          end
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

        def remote_gateway_attributes
          ps_trm_gw.merge(
            name: phone_systems_gateway_name,
            authorization_name: authorization_name,
            authorization_password: authorization_password
          )
        end

        # Symbolized so that re-merging the credentials in #remote_gateway_attributes
        # replaces the configured keys instead of adding a second copy of each under a
        # symbol key next to the string one that came from the JSONB variables.
        def ps_trm_gw
          return @ps_trm_gw if defined?(@ps_trm_gw)

          @ps_trm_gw = @service_variables['ps_trm_gw'].presence&.symbolize_keys
        end

        # ps_trm_gw wins: whatever the operator configured is what gets provisioned into
        # the phone.systems gateway AND into the incoming auth of the Yeti gateway. A pair
        # is generated only for what the variables leave undefined.
        def authorization_name
          @authorization_name ||= ps_trm_gw[:authorization_name].presence || generate_auth_credential
        end

        def authorization_password
          @authorization_password ||= ps_trm_gw[:authorization_password].presence || generate_auth_credential
        end

        def yeti_gateway_name
          "ps-#{@service.id}"
        end

        def phone_systems_gateway_name
          "gw-#{@service.uuid}"
        end

        def generate_auth_credential
          SecureRandom.alphanumeric(AUTH_CREDENTIAL_LENGTH)
        end
      end
    end
  end
end
