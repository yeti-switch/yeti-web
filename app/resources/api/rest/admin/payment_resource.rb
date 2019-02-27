# frozen_string_literal: true

class Api::Rest::Admin::PaymentResource < BaseResource
  attributes :amount, :notes

  has_one :account

  ransack_filter :amount, type: :number
  ransack_filter :notes, type: :string

  def self.updatable_fields(_context)
    %i[
      account
      amount
      notes
    ]
  end

  def self.creatable_fields(context)
    updatable_fields(context)
  end
end
