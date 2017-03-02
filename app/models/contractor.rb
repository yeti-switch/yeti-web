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
#

class Contractor < ActiveRecord::Base
  has_many :gateways, dependent: :restrict_with_error
  has_many :gateway_groups, foreign_key: :vendor_id, dependent: :restrict_with_error
  has_many :customers_auths, foreign_key: :customer_id, dependent: :restrict_with_error
  has_many :accounts, dependent: :restrict_with_error
  has_many :contacts, class_name: 'Billing::Contact', foreign_key: 'contractor_id', dependent: :delete_all
  belongs_to :smtp_connection, class_name: 'System::SmtpConnection'

  has_paper_trail class_name: 'AuditLogItem'


  scope :customers, -> { where customer: true }
  scope :vendors, -> { where vendor: true }

  include Yeti::ResourceStatus


  validate :vendor_or_customer?
  validates_presence_of :name
  validates_uniqueness_of :name

  def display_name
    "#{self.name} | #{self.id}"
  end

  def is_enabled?
    self.enabled
  end

  private

  def vendor_or_customer?
    unless customer? or vendor?
      errors.add :vendor, "Must be customer and/or vendor"
      errors.add :customer, "Must be customer and/or vendor"
    end
  end

end
  
