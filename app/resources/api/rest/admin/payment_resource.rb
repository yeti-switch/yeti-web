# frozen_string_literal: true

class Api::Rest::Admin::PaymentResource < JSONAPI::Resource
  attributes :amount, :notes

  has_one :account

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
