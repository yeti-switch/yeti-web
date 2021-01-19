# frozen_string_literal: true

class Api::Rest::Admin::PaymentResource < BaseResource
  attributes :amount, :notes

  paginator :paged

  has_one :account

  ransack_filter :amount, type: :number
  ransack_filter :notes, type: :string

  def self.creatable_fields(_context)
    %i[
      account
      amount
      notes
    ]
  end
end
