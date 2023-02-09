# frozen_string_literal: true

module Jobs
  class DeleteAppliedRateManagementPricelists < ::BaseJob
    self.cron_line = '0 2 * * *' # 02:00 every day

    def execute
      ApplicationRecord.transaction do
        pricelists_scope = RateManagement::Pricelist.old_applied
        RateManagement::PricelistItem.joins(:pricelist).merge(pricelists_scope).delete_all
        pricelists_scope.delete_all
      end
    end
  end
end
