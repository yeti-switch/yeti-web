# frozen_string_literal: true

class DeleteDialpeers < ApplicationService
  parameter :dialpeer_ids, required: true

  def call
    ApplicationRecord.transaction do
      DialpeerNextRate.delete_by(dialpeer_id: dialpeer_ids)
      Dialpeer.delete_by(id: dialpeer_ids)
    end
  end
end
