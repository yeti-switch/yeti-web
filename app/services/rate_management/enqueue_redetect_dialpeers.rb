# frozen_string_literal: true

module RateManagement
  # This service prevents simultaneous running of several Detect Dialpeers background jobs.
  class EnqueueRedetectDialpeers < ApplicationService
    parameter :pricelist, required: true

    Error = Class.new(StandardError)

    def call
      pricelist.with_lock do
        raise_if_invalid!
        pricelist.update!(detect_dialpeers_in_progress: true)
        Worker::RateManagementRedetectDialpeers.perform_later(pricelist.id)
      end
    end

    private

    def raise_if_invalid!
      raise Error, 'Pricelist must be in Dialpeers detected state' unless pricelist.dialpeers_detected?
      raise Error, 'Dialpeers detection already in progress' if pricelist.detect_dialpeers_in_progress?
      raise Error, 'Applying changes already in progress' if pricelist.apply_changes_in_progress?
    end
  end
end
