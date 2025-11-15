# frozen_string_literal: true

module CustomerV1Auth
  class AuthContext < Data.define(
    :api_access_id,
    :account_ids,
    :allow_listen_recording,
    :allow_outgoing_numberlists_ids,
    :allowed_ips,
    :login,
    :customer_id,
    :customer_portal_access_profile_id,
    :provision_gateway_id
  )

    def self.from_api_access(api_access)
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

    def provision_gateway
      Gateway.find_by(id: provision_gateway_id)
    end

    def customer
      Contractor.find_by(id: customer_id)
    end
  end
end
