# == Schema Information
#
# Table name: sys.api_access
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  login       :string           not null
#  password    :string           not null
#  account_ids :integer          is an Array
#  allowed_ips :inet             default("{0.0.0.0/0}"), is an Array
#

class System::ApiAccess < ActiveRecord::Base
  self.table_name = 'sys.api_access'

  has_secure_password

  belongs_to :customer, class_name: 'Contractor', foreign_key: :customer_id

  validates_uniqueness_of :login
  validates_presence_of :login, :customer

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
    read_attribute_before_type_cast('allowed_ips')[1..-2]
  end

  def accounts
    unless account_ids.empty?
      Account.where(id: account_ids)
    else
      []
    end
  end

  # Auth

  def authenticate_ip(remote_ip)
    allowed_ips.any? { |ip| ip.include?(remote_ip) }
  end

  def self.from_token_request(request)
    self.where(login: request.params[:auth][:login]).take
  end

  #force update Allowed IPs
  def keys_for_partial_write
    (changed + ['allowed_ips']).uniq
  end

  def name
    "#{id} | #{login}"
  end

  private

  def allowed_ips_is_valid
    begin
      read_attribute_before_type_cast('allowed_ips').each do |raw_ip|
        _tmp = IPAddr.new(raw_ip)
      end if read_attribute_before_type_cast('allowed_ips').is_a?(Array)
    rescue IPAddr::Error => error
      self.errors.add(:allowed_ips, "Allowed IP is not valid")
    end
  end

end
