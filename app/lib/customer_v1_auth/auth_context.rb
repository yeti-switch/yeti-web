# frozen_string_literal: true

module CustomerV1Auth
  class AuthContext < DataTransferObject
    attribute :customer_id
    attribute :customer_portal_access_profile_id, default: 1
    attribute :api_access_id
    attribute :login
    attribute :account_ids, default: []
    attribute :allow_listen_recording, default: false
    attribute :allow_outgoing_numberlists_ids, default: []
    attribute :allowed_ips, default: ['0.0.0.0/0', '::/0']
    attribute :provision_gateway_id

    class << self
      def from_config(config)
        config = config.symbolize_keys
        allowed = members - %i[api_access_id login]
        config.assert_valid_keys(*allowed)
        raise ArgumentError, 'customer_id is required' if config[:customer_id].nil?

        new(**config)
      end

      def from_api_access(api_access)
        new(
          api_access_id: api_access.id,
          account_ids: api_access.account_ids,
          allow_listen_recording: api_access.allow_listen_recording,
          allow_outgoing_numberlists_ids: api_access.allow_outgoing_numberlists_ids,
          allowed_ips: api_access.allowed_ips,
          login: api_access.login,
          customer_id: api_access.customer_id,
          customer_portal_access_profile_id: api_access.customer_portal_access_profile_id,
          provision_gateway_id: api_access.provision_gateway_id
        )
      end
    end

    define_memoizable :customer, apply: lambda {
      Contractor.find_by(id: customer_id)
    }

    define_memoizable :customer_portal_access_profile, apply: lambda {
      System::CustomerPortalAccessProfile.find_by(id: customer_portal_access_profile_id)
    }

    define_memoizable :provision_gateway, apply: lambda {
      Gateway.find_by(id: provision_gateway_id) if provision_gateway_id
    }

    def allow_outgoing_numberlists
      Routing::Numberlist.where(id: allow_outgoing_numberlists_ids)
    end

    def find_allowed_account(uuid)
      if account_ids.empty?
        Account.find_by(contractor_id: customer_id, uuid:)
      else
        Account.find_by(id: account_ids, contractor_id: customer_id, uuid:)
      end
    end

    def to_config
      to_h.except(:api_access_id, :login)
    end
  end
end
