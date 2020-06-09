# frozen_string_literal: true

class BatchUpdateForm::Contractor < BatchUpdateForm::Base
  model_class 'Contractor'
  attribute :enabled, type: :boolean
  attribute :vendor, type: :boolean
  attribute :customer, type: :boolean
  attribute :description
  attribute :address
  attribute :phones
  attribute :smtp_connection_id, type: :foreign_key, class_name: 'System::SmtpConnection'

  validates :vendor, required_with: :customer

  validate if: -> { customer_changed? || vendor_changed? } do
    if !customer && !vendor
      errors.add :base, I18n.t('activerecord.errors.models.contractor.vendor_and_customer')
    elsif customer
      errors.add :base, I18n.t('activerecord.errors.models.contractor.vendor_and_customer') if vendor
    elsif vendor
      errors.add :base, I18n.t('activerecord.errors.models.contractor.vendor_and_customer') if customer
    end
  end

  validate :without_customers_auths

  def without_customers_auths
    if errors.messages.blank? && (!customer && vendor)
      errors.add(:customer, I18n.t('activerecord.errors.models.contractor.attributes.customer')) if customers_auth_any?
    end
  end

  def customers_auth_any?
    CustomersAuth.where(customer_id: selected_record || Contractor.select(:id)).any?
  end
end
