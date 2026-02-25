# frozen_string_literal: true

class Api::Rest::Admin::CustomerTokenResource < BaseResource
  model_name 'CustomerTokenForm'

  attributes :allowed_ips,
             :customer_portal_access_profile_id,
             :token,
             :expires_at

  has_one :customer, class_name: 'Contractor'
  has_many :accounts, class_name: 'Account'
  has_many :allow_outgoing_numberlists, class_name: 'Numberlist'
  has_one :provision_gateway, class_name: 'Gateway'

  def fetchable_fields
    %i[token expires_at]
  end

  def self.creatable_fields(_context)
    %i[
      customer
      accounts
      allow_outgoing_numberlists
      provision_gateway
      allowed_ips
      customer_portal_access_profile_id
    ]
  end
end
