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

  validates :name, presence: true
  validates :name, uniqueness: true, allow_blank: true
  validates :provisioning_class, presence: true
  validate :validate_provisioning_class
  validates :force_renew, inclusion: { in: [true, false] }
  validate :validate_variables

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
    errors.add(:variables, 'must be a JSON object or empty') if !variables.nil? && !variables.is_a?(Hash)
  end
end
