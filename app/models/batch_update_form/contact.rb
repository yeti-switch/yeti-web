# frozen_string_literal: true

class BatchUpdateForm::Contact < BatchUpdateForm::Base
  model_class 'Billing::Contact'
  attribute :contractor_id, type: :foreign_key, class_name: 'Contractor'
  attribute :admin_user_id, type: :foreign_key, class_name: 'AdminUser', display_name: :username
  attribute :email
  attribute :notes

  validates :email, presence: true, if: :email_changed?
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, message: 'must be matched to the following format john@deer.ua' }, if: :email_changed?
end
