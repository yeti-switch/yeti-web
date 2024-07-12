# frozen_string_literal: true

# == Schema Information
#
# Table name: billing.service_types
#
#  id                 :integer(2)       not null, primary key
#  force_renew        :boolean          default(FALSE), not null
#  name               :string           not null
#  provisioning_class :string
#  variables          :jsonb
#
# Indexes
#
#  service_types_name_key  (name) UNIQUE
#
class Billing::ServiceType < ApplicationRecord
  self.table_name = 'billing.service_types'

  include WithPaperTrail

  has_many :services, class_name: 'Billing::Service', foreign_key: :type_id, dependent: :restrict_with_error

  before_validation { self.variables = nil if variables.blank? }

  validates :name, presence: true
  validates :name, uniqueness: true, allow_blank: true
  validates :provisioning_class, presence: true
  validate :validate_provisioning_class
  validates :force_renew, inclusion: { in: [true, false] }
  validate :validate_variables

  before_create :verify_provisioning_variables
  before_update :verify_provisioning_variables, if: proc { variables_changed? || provisioning_class_changed? }

  def display_name
    name
  end

  def variables_json
    return if variables.nil?
    # need to show invalid variables JSON as is in new/edit form.
    return variables if variables.is_a?(String)

    JSON.generate(variables)
  end

  def variables_json=(value)
    self.variables = value.blank? ? nil : JSON.parse(value)
  rescue JSON::ParserError
    # need to show invalid variables JSON as is in new/edit form.
    self.variables = value
  end

  private

  def validate_provisioning_class
    return if provisioning_class.blank?

    klass = provisioning_class.safe_constantize
    if klass.nil? || !klass.is_a?(Class) || !(klass < Billing::Provisioning::Base)
      errors.add(:provisioning_class, :invalid)
      return
    end

    if persisted? && services.any? && attribute_changed?(:provisioning_class)
      errors.add(:provisioning_class, "can't be changed because have linked services")
    end
  end

  def validate_variables
    if !variables.nil? && !variables.is_a?(Hash)
      errors.add(:variables, 'must be a JSON object or empty')
    end
  end

  def verify_provisioning_variables
    klass = provisioning_class.constantize
    self.variables = klass.verify_service_type_variables!(self)
  rescue Billing::Provisioning::Errors::InvalidVariablesError => e
    e.full_error_messages.each { |msg| errors.add(:variables, msg) }
    throw(:abort)
  end
end
