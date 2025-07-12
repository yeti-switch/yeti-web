# frozen_string_literal: true

# == Schema Information
#
# Table name: contractors
#
#  id                 :integer(4)       not null, primary key
#  address            :string
#  customer           :boolean          not null
#  description        :string
#  enabled            :boolean          not null
#  name               :string           not null
#  phones             :string
#  vendor             :boolean          not null
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

class Contractor < ApplicationRecord
  has_many :gateways, dependent: :restrict_with_error
  has_many :gateway_groups, foreign_key: :vendor_id, dependent: :restrict_with_error
  has_many :customers_auths, foreign_key: :customer_id, dependent: :restrict_with_error
  has_many :rateplans, through: :customers_auths, class_name: 'Routing::Rateplan'
  has_many :accounts, dependent: :restrict_with_error
  has_many :contacts, class_name: 'Billing::Contact', foreign_key: 'contractor_id', dependent: :delete_all
  has_many :api_access, class_name: 'System::ApiAccess', foreign_key: 'customer_id', dependent: :destroy
  has_many :active_rate_management_pricelist_items,
           -> { not_applied },
           class_name: 'RateManagement::PricelistItem',
           foreign_key: :vendor_id
  has_many :applied_rate_management_pricelist_items,
           -> { applied },
           class_name: 'RateManagement::PricelistItem',
           dependent: :nullify,
           foreign_key: :vendor_id

  has_many :traffic_sampling_rules, class_name: 'Routing::TrafficSamplingRule', foreign_key: :customer_id, dependent: :destroy

  belongs_to :smtp_connection, class_name: 'System::SmtpConnection', optional: true

  include WithPaperTrail

  scope :customers, -> { where customer: true }
  scope :vendors, -> { where vendor: true }
  scope :search_for, ->(term) { where("contractors.name || ' | ' || contractors.id::varchar ILIKE ?", "%#{term}%") }
  scope :ordered_by, ->(term) { order(term) }

  include Yeti::ResourceStatus

  validate :vendor_or_customer?
  validate :customer_can_be_disabled
  validates :name, presence: true
  validates :name, uniqueness: true
  validates :external_id, uniqueness: { allow_blank: true }

  before_destroy :check_associated_records

  def display_name
    "#{name} | #{id}"
  end

  def is_enabled?
    enabled
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

  def check_associated_records
    pricelist_ids = active_rate_management_pricelist_items.pluck(Arel.sql('DISTINCT(pricelist_id)'))
    if pricelist_ids.any?
      errors.add(:base, "Can't be deleted because linked to not applied Rate Management Pricelist(s) ##{pricelist_ids.join(', #')}")
      throw(:abort)
    end
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[
      search_for ordered_by
    ]
  end
end
