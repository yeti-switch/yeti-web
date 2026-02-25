# frozen_string_literal: true

class CustomerTokenForm < ApplicationForm
  def self.policy_class = System::CustomerTokenPolicy

  attr_reader :token, :expires_at

  attribute :customer_id, :integer
  attribute :account_ids, :integer, array: true, default: []
  attribute :allow_outgoing_numberlist_ids, :integer, array: true, default: []
  attribute :allowed_ips, :string, array: true, default: %w[0.0.0.0/0 ::/0]
  attribute :customer_portal_access_profile_id, :integer, default: 1
  attribute :provision_gateway_id, :integer

  normalize_attribute :account_ids, with: ->(account_ids) { account_ids.reject(&:nil?).uniq.sort }
  normalize_attribute :allow_outgoing_numberlist_ids, with: ->(nl_ids) { nl_ids.reject(&:nil?).uniq.sort }

  validates :customer, presence: true
  validates :customer_portal_access_profile, presence: true
  validates :provision_gateway, presence: true, if: :provision_gateway_id
  validate :validate_allowed_ips
  validate :validate_account_ids

  define_memoizable :customer, apply: lambda {
    Contractor.find_by(id: customer_id) if customer_id
  }

  define_memoizable :customer_portal_access_profile, apply: lambda {
    return if customer_portal_access_profile_id.nil?

    System::CustomerPortalAccessProfile.find_by(id: customer_portal_access_profile_id)
  }

  define_memoizable :provision_gateway, apply: lambda {
    Gateway.find_by(id: provision_gateway_id) if provision_gateway_id
  }

  def id
    persisted? ? customer_id : nil
  end

  def persisted?
    token.present?
  end

  private

  def _save
    auth_context = CustomerV1Auth::AuthContext.from_config(
      customer_id: customer_id,
      account_ids: account_ids,
      allow_outgoing_numberlists_ids: allow_outgoing_numberlist_ids,
      allowed_ips: allowed_ips,
      customer_portal_access_profile_id: customer_portal_access_profile_id,
      provision_gateway_id: provision_gateway_id
    )
    result = CustomerV1Auth::Authenticator.build_auth_data(auth_context)
    @token = result.token
    @expires_at = result.expires_at
  end

  def validate_account_ids
    return if customer_id.nil?

    if account_ids.size < Account.where(id: account_ids, contractor_id: customer_id).count
      errors.add(:account_ids, 'Account should be connected with selected Customer')
    end
  end

  def validate_allowed_ips
    return unless allowed_ips.is_a?(Array)

    allowed_ips.each { |raw_ip| IPAddr.new(raw_ip) }
  rescue IPAddr::Error => _e
    errors.add(:allowed_ips, 'Allowed IP is not valid')
  end
end
