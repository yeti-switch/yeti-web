# frozen_string_literal: true

module Jobs
  class DeleteExpiredDialpeers < ::BaseJob
    self.cron_line = '0 0 * * *'

    def execute
      return if expired_date.nil?

      dialpeer_ids = expired_dialpeer_ids
      DeleteDialpeers.call(dialpeer_ids: dialpeer_ids) if dialpeer_ids.present?
    end

    private

    def expired_dialpeer_ids
      Dialpeer.where('valid_till <= ?', expired_date).pluck(:id)
    end

    def expired_date
      return @expired_date if instance_variable_defined?(:@expired_date)

      keep_expired_days = YetiConfig.keep_expired_dialpeers_days
      @expired_date = keep_expired_days.days.ago if keep_expired_days.present?
    end
  end
end
