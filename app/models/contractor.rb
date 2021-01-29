# frozen_string_literal: true

# == Schema Information
#
# Table name: contractors
#
#  id                 :integer(4)       not null, primary key
#  address            :string
#  customer           :boolean
#  description        :string
#  enabled            :boolean
#  name               :string
#  phones             :string
#  vendor             :boolean
#  external_id        :bigint(8)
#  smtp_connection_id :integer(4)
#
# Indexes
#
#  contractors_external_id_key  (external_id) UNIQUE
#  contractors_name_unique      (name) UNIQUE
#
# Foreign Keys
#
#  contractors_smtp_connection_id_fkey  (smtp_connection_id => smtp_connections.id)
#

class Contractor < ActiveRecord::Base
  has_many :gateways, dependent: :restrict_with_error
  has_many :gateway_groups, foreign_key: :vendor_id, dependent: :restrict_with_error
  has_many :customers_auths, foreign_key: :customer_id, dependent: :restrict_with_error
  has_many :rateplans, through: :customers_auths, class_name: 'Routing::Rateplan'
  has_many :accounts, dependent: :restrict_with_error
  has_many :contacts, class_name: 'Billing::Contact', foreign_key: 'contractor_id', dependent: :delete_all
  has_many :api_access, class_name: 'System::ApiAccess', foreign_key: 'customer_id', dependent: :destroy
  belongs_to :smtp_connection, class_name: 'System::SmtpConnection'

  include WithPaperTrail

  scope :customers, -> { where customer: true }
  scope :vendors, -> { where vendor: true }
  scope :search_for, ->(term) { where("name || ' | ' || id::varchar ILIKE ?", "%#{term}%") }
  scope :ordered_by, ->(term) { order(term) }

  include Yeti::ResourceStatus

  validate :vendor_or_customer?
  validate :customer_can_be_disabled
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :external_id, uniqueness: { allow_blank: true }

  def display_name
    "#{name} | #{id}"
  end

  def is_enabled?
    enabled
  end

  def for_origination_gateways
    Gateway.for_origination(id)
  end

  def for_termination_gateways
    Gateway.for_termination(id)
  end

  private

  def vendor_or_customer?
    unless customer? || vendor?
      errors.add :vendor, 'Must be customer and/or vendor'
      errors.add :customer, 'Must be customer and/or vendor'
    end
  end

  def customer_can_be_disabled
    if customer_changed?(from: true, to: false) && customers_auths.any?
      errors.add(:customer, I18n.t('activerecord.errors.models.contractor.attributes.customer'))
    end
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      search_for ordered_by
    ]
  end
end
