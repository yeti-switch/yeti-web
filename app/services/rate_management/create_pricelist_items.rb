# frozen_string_literal: true

module RateManagement
  class CreatePricelistItems < ApplicationService
    parameter :pricelist_items_attrs, required: true
    parameter :pricelist, required: true

    Error = Class.new(StandardError)
    InvalidAttributesError = Class.new(StandardError)

    def call
      ApplicationRecord.transaction do
        raise_if_invalid!
        RateManagement::PricelistItem.insert_all!(pricelist_items_attrs)
        pricelist.update!(items_count: pricelist_items_attrs.size)
      rescue ActiveRecord::RecordInvalid => e
        raise Error, e.message
      end
    end

    private

    def raise_if_invalid!
      raise Error, 'Pricelist must be exist' if pricelist.nil?
      raise InvalidAttributesError, 'must be filled at least 1 item' if pricelist_items_attrs.blank?
    end
  end
end
