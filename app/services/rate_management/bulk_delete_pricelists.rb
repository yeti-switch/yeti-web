# frozen_string_literal: true

module RateManagement
  class BulkDeletePricelists < ApplicationService
    parameter :pricelist_ids, required: true

    def call
      ApplicationRecord.transaction do
        RateManagement::PricelistItem.where(pricelist_id: pricelist_ids).delete_all
        RateManagement::Pricelist.where(id: pricelist_ids).delete_all
      end
    end
  end
end
