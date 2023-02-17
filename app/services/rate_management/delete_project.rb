# frozen_string_literal: true

module RateManagement
  class DeleteProject < ApplicationService
    parameter :project, required: true

    def call
      ApplicationRecord.transaction do
        pricelist_ids = project.pricelists.pluck(:id)
        RateManagement::BulkDeletePricelists.call(pricelist_ids: pricelist_ids) if pricelist_ids.any?
        project.destroy!
      end
    end
  end
end
