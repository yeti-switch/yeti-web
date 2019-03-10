# == Schema Information
#
# Table name: contractors
#
#  id                 :integer          not null, primary key
#  name               :string
#  enabled            :boolean
#  vendor             :boolean
#  customer           :boolean
#  description        :string
#  address            :string
#  phones             :string
#  smtp_connection_id :integer
#  external_id        :integer
#

class Contractor < ActiveRecord::Base
  has_many :gateways, dependent: :restrict_with_error
  has_many :gateway_groups, foreign_key: :vendor_id, dependent: :restrict_with_error
  has_many :customers_auths, foreign_key: :customer_id, dependent: :restrict_with_error
  has_many :rateplans, through: :customers_auths
  has_many :accounts, dependent: :restrict_with_error
  has_many :contacts, class_name: 'Billing::Contact', foreign_key: 'contractor_id', dependent: :delete_all
  has_many :api_access, class_name: 'System::ApiAccess', foreign_key: 'customer_id', dependent: :destroy
  belongs_to :smtp_connection, class_name: 'System::SmtpConnection'

  has_paper_trail class_name: 'AuditLogItem'


  scope :customers, -> { where customer: true }
  scope :vendors, -> { where vendor: true }

  include Yeti::ResourceStatus


  validate :vendor_or_customer?
  validate :customer_can_be_disabled
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_uniqueness_of :external_id, allow_blank: true

  def display_name
    "#{self.name} | #{self.id}"
  end

  def is_enabled?
    self.enabled
  end

  def for_origination_gateways
    Gateway.for_origination(id)
  end

  def for_termination_gateways
    Gateway.for_termination(id)
  end

  private

  def vendor_or_customer?
    unless customer? or vendor?
      errors.add :vendor, "Must be customer and/or vendor"
      errors.add :customer, "Must be customer and/or vendor"
    end
  end

  def customer_can_be_disabled
    if customer_changed?(from: true, to: false) && customers_auths.any?
      errors.add(:customer, I18n.t('activerecord.errors.models.contractor.attributes.customer'))
    end
  end
end

