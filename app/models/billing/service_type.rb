# == Schema Information
#
# Table name: service_types
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
  self.table_name = 'service_types'

  include WithPaperTrail

  has_many :services, class_name: 'Billing::Service', foreign_key: :type_id, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
  validate :provisioning_class_immutable

  protected
  def provisioning_class_immutable
    if provisioning_class_changed?
      errors.add(:provisioning_class, I18n.t('activerecord.errors.models.billing.service_type.provisioning_class_immutable')) if services.any?
    end
  end

end
