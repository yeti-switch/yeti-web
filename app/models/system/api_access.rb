# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.api_access
#
#  id              :integer(4)       not null, primary key
#  account_ids     :integer(4)       default([]), not null, is an Array
#  allowed_ips     :inet             default(["\"0.0.0.0/0\""]), not null, is an Array
#  login           :string           not null
#  password_digest :string           not null
#  customer_id     :integer(4)       not null
#
# Indexes
#
#  api_access_login_key  (login) UNIQUE
#
# Foreign Keys
#
#  api_access_customer_id_fkey  (customer_id => contractors.id)
#

class System::ApiAccess < ApplicationRecord
  self.table_name = 'sys.api_access'

  has_secure_password

  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id

  validates :login, uniqueness: true
  validates :login, :customer, presence: true

  validate :allowed_ips_is_valid

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

  def accounts
    if account_ids.empty?
      []
    else
      Account.where(id: account_ids)
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
    "#{id} | #{login}"
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
