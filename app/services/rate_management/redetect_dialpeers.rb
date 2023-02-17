# frozen_string_literal: true

module RateManagement
  class RedetectDialpeers < ApplicationService
    parameter :pricelist, required: true

    Error = Class.new(StandardError)

    def call
      pricelist.with_lock do
        raise_if_invalid!

        revert_pricelist_to_new_state
        RateManagement::DetectDialpeers.call(pricelist: pricelist)
      end
    end

    private

    def raise_if_invalid!
      raise Error, 'pricelist must be in Dialpeers detected state' unless pricelist.dialpeers_detected?
    end

    def revert_pricelist_to_new_state
      pricelist.items.to_delete.delete_all
      pricelist.items.update_all(dialpeer_id: nil, detected_dialpeer_ids: [])

      # RateManagement::DetectDialpeersForPricelistItems requires pricelist to be in NEW state
      # so we change state inside transaction.
      # After RateManagement::DetectDialpeersForPricelistItems finished it will be "Dialpeers detected" again.
      pricelist.update!(state_id: RateManagement::Pricelist::CONST::STATE_ID_NEW)
    end
  end
end
