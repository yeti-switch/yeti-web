# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.api_access
#
#  id                                :integer(4)       not null, primary key
#  account_ids                       :integer(4)       default([]), not null, is an Array
#  allow_outgoing_numberlists_ids    :integer(4)       default([]), not null, is an Array
#  allowed_ips                       :inet             default(["\"0.0.0.0/0\"", "\"::/0\""]), not null, is an Array
#  login                             :string           not null
#  password_digest                   :string           not null
#  created_at                        :timestamptz
#  updated_at                        :timestamptz
#  customer_id                       :integer(4)       not null
#  customer_portal_access_profile_id :integer(2)       default(1), not null
#  provision_gateway_id              :integer(4)
#
# Indexes
#
#  api_access_customer_id_idx                             (customer_id)
#  api_access_login_key                                   (login) UNIQUE
#  api_access_provision_gateway_id_idx                    (provision_gateway_id)
#  index_api_access_on_customer_portal_access_profile_id  (customer_portal_access_profile_id)
#
# Foreign Keys
#
#  api_access_customer_id_fkey           (customer_id => contractors.id)
#  api_access_provision_gateway_id_fkey  (provision_gateway_id => gateways.id)
#  fk_rails_01e2f85455                   (customer_portal_access_profile_id => customer_portal_access_profiles.id)
#

class System::ApiAccess < ApplicationRecord
  self.table_name = 'sys.api_access'

  has_secure_password

  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id
  belongs_to :provision_gateway, class_name: 'Gateway', foreign_key: :provision_gateway_id, optional: true
  belongs_to :customer_portal_access_profile, class_name: 'System::CustomerPortalAccessProfile'

  validates :login, uniqueness: true
  validates :login, :customer, presence: true

  validate :allowed_ips_is_valid
  include WithPaperTrail

  validate if: :customer_id do |record|
    if record.account_ids
      record.account_ids.reject!(&:blank?)
      record.account_ids.each do |account_id|
        unless Account.exists?(id: account_id, contractor_id: record.customer_id)
          errors.add(:base, 'Account should be connected with selected Customer')
        end
      end
    end
  end

  def formtastic_allowed_ips=(str)
    @formtastic_allowed_ips = str
    self.allowed_ips = str.split(',').map(&:strip)
  end

  def formtastic_allowed_ips
    allowed_ips.map(&:strip).join(', ')
  end

  def allow_outgoing_numberlists_ids=(s)
    # form sends empty array element, we have to remove it
    self[:allow_outgoing_numberlists_ids] = s.uniq.sort.reject(&:blank?)
  end

  def allow_outgoing_numberlists
    Routing::Numberlist.where(id: allow_outgoing_numberlists_ids)
  end

  def accounts
    if account_ids.empty?
      []
    else
      Account.where(id: account_ids)
    end
  end

  def find_allowed_account(uuid)
    if account_ids.empty?
      Account.find_by(contractor_id: customer_id, uuid:)
    else
      Account.find_by(id: account_ids, uuid:)
    end
  end

  # Auth

  def authenticate_ip(remote_ip)
    allowed_ips.any? { |ip| IPAddr.new(ip).include?(remote_ip) }
  end

  def self.from_token_request(request)
    find_by(login: request.params[:auth][:login])
  end

  # force update Allowed IPs
  def keys_for_partial_write
    (changed + ['allowed_ips']).uniq
  end

  def name
    "#{login} | #{id}"
  end

  private

  def allowed_ips_is_valid
    if read_attribute_before_type_cast('allowed_ips').is_a?(Array)
      read_attribute_before_type_cast('allowed_ips').each do |raw_ip|
        _tmp = IPAddr.new(raw_ip)
      end
    end
  rescue IPAddr::Error => error
    errors.add(:allowed_ips, 'Allowed IP is not valid')
  end
end
