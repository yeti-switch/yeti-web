# frozen_string_literal: true

class BatchUpdateForm::Payment < BatchUpdateForm::Base
  model_class 'Payment'
  attribute :account_id, type: :foreign_key, class_name: 'Account'
  attribute :amount
  attribute :notes

  validates :amount, presence: true, if: :amount_changed?
  validates :amount, numericality: true, if: :amount_changed?
end
