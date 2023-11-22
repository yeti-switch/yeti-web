# frozen_string_literal: true

class Billing::InvoiceState < ApplicationEnum
  PENDING = 1
  APPROVED = 2
  NEW = 3

  setup_collection do
    [
      { id: PENDING, name: 'Pending' },
      { id: APPROVED, name: 'Approved' },
      { id: NEW, name: 'New' }
    ]
  end

  attribute :name

  def pending?
    id == PENDING
  end
end
