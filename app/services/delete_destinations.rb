# frozen_string_literal: true

class DeleteDestinations < ApplicationService
  parameter :destination_ids, required: true

  def call
    ApplicationRecord.transaction do
      Routing::DestinationNextRate.delete_by(destination_id: destination_ids)
      Routing::Destination.delete_by(id: destination_ids)
    end
  end
end
