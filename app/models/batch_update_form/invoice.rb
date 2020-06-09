# frozen_string_literal: true

class BatchUpdateForm::Invoice < BatchUpdateForm::Base
  model_class 'Billing::Invoice'
  attribute :contractor_id, type: :foreign_key, class_name: 'Contractor'
  attribute :account_id, type: :foreign_key, class_name: 'Account'
  attribute :state_id, type: :foreign_key, class_name: 'Billing::InvoiceState'
  attribute :start_date, type: :date
  attribute :end_date, type: :date
  attribute :amount
  attribute :type_id, type: :foreign_key, class_name: 'Billing::InvoiceType'
  attribute :vendor_invoice, type: :boolean

  # presence
  validates :start_date, presence: true, if: :start_date_changed?
  validates :end_date, presence: true, if: :end_date_changed?
  validates :amount, presence: true, if: :amount_changed?

  # required with
  validates :start_date, required_with: :end_date
  validates :account_id, required_with: :contractor_id
  validates :vendor_invoice, required_with: { with: :contractor_id, both_direction: false }

  # numericality
  validates :amount, numericality: true, if: :amount_changed?

  # other
  validate :account_owners_contractor

  validates_date :start_date, on_or_before: :end_date, if: %i[start_date_changed? end_date_changed?]

  validate if: %i[vendor_invoice_changed? contractor_id_changed?] do
    errors.add(:vendor_invoice, 'selected Contractor is not a vendor or choose vendor_invoice in No') if is_customer?(contractor_id) && vendor_invoice
  end

  def account_owners_contractor
    return true if account_id.nil?

    account = Account.find_by(id: account_id.to_i)
    errors.add(:contractor_id, "must be owners by selected account, for example account: #{account&.name}, contractor: #{account&.contractor&.name}") if account&.contractor_id != contractor_id.to_i
  end

  def is_customer?(id)
    Contractor.find_by(id: id)&.customer?
  end
end
