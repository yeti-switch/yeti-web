# frozen_string_literal: true

class Api::Rest::Admin::PaymentResource < BaseResource
  attributes :amount, :notes, :status

  paginator :paged

  has_one :account

  ransack_filter :amount, type: :number
  ransack_filter :notes, type: :string
  ransack_filter :status, type: :enum, collection: Payment::CONST::STATUS_IDS.values

  def self.creatable_fields(_context)
    %i[
      account
      amount
      notes
    ]
  end

  def self.sortable_fields(_context)
    %i[amount notes]
  end
end
