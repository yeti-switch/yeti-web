# frozen_string_literal: true

module DestinationNextRate
  class BulkDelete < ApplicationService
    parameter :next_rate_ids, required: true

    def call
      Routing::DestinationNextRate.delete_by(id: next_rate_ids)
    end
  end
end
