# frozen_string_literal: true

class Billing::InvoiceType < ApplicationEnum
  MANUAL = 1
  AUTO_FULL = 2
  AUTO_PARTIAL = 3

  setup_collection do
    [
      { id: MANUAL, name: 'Manual' },
      { id: AUTO_FULL, name: 'Auto Full' },
      { id: AUTO_PARTIAL, name: 'Auto Partial' }
    ]
  end

  attribute :name
end
