# frozen_string_literal: true

class Api::Rest::Admin::PaymentResource < BaseResource
  attributes :created_at,
             :amount,
             :notes,
             :private_notes,
             :status,
             :type_name,
             :balance_before_payment

  paginator :paged

  has_one :account, always_include_linkage_data: true

  relationship_filter :account

  ransack_filter :id, type: :number
  ransack_filter :created_at, type: :datetime
  ransack_filter :amount, type: :number
  ransack_filter :notes, type: :string
  ransack_filter :private_notes, type: :string
  ransack_filter :status, type: :enum, collection: Payment::CONST::STATUS_IDS.values
  ransack_filter :type_name, type: :enum, collection: Payment::CONST::TYPE_IDS.values

  def self.creatable_fields(_context)
    %i[
      account
      amount
      notes
      private_notes
    ]
  end

  def self.sortable_fields(_context)
    %i[amount created_at]
  end
end
