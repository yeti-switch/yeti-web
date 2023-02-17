# frozen_string_literal: true

module RateManagement
  # This service prevents simultaneous running of several Apply Changes background jobs.
  class EnqueueApplyChanges < ApplicationService
    parameter :pricelist, required: true

    Error = Class.new(StandardError)

    def call
      pricelist.with_lock do
        raise_if_invalid!
        pricelist.update!(apply_changes_in_progress: true)
        Worker::RateManagementApplyChanges.perform_later(pricelist.id)
      end
    end

    private

    def raise_if_invalid!
      raise Error, 'Pricelist must be in Dialpeers detected state' unless pricelist.dialpeers_detected?
      raise Error, 'Dialpeers detection already in progress' if pricelist.detect_dialpeers_in_progress?
      raise Error, 'Applying changes already in progress' if pricelist.apply_changes_in_progress?
      raise Error, 'Pricelist valid_till must be in the future' unless pricelist.valid_till.future?
    end
  end
end
