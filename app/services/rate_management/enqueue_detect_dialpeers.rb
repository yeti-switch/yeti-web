# frozen_string_literal: true

module RateManagement
  # This service prevents simultaneous running of several Detect Dialpeers background jobs.
  class EnqueueDetectDialpeers < ApplicationService
    parameter :pricelist, required: true

    Error = Class.new(StandardError)

    def call
      pricelist.with_lock do
        raise_if_invalid!
        pricelist.update!(detect_dialpeers_in_progress: true)
        Worker::RateManagementDetectDialpeers.perform_later(pricelist.id)
      end
    end

    private

    def raise_if_invalid!
      raise Error, 'Pricelist must be in New state' unless pricelist.new?
      raise Error, 'Dialpeers detection already in progress' if pricelist.detect_dialpeers_in_progress?
    end
  end
end
