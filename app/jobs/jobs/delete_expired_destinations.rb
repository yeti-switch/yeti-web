# frozen_string_literal: true

module Jobs
  class DeleteExpiredDestinations < ::BaseJob
    self.cron_line = '0 0 * * *'

    def execute
      return if expired_date.nil?

      destination_ids = expired_destination_ids
      DeleteDestinations.call(destination_ids: destination_ids) if destination_ids.present?
    end

    private

    def expired_destination_ids
      Routing::Destination.where('valid_till <= ?', expired_date).pluck(:id)
    end

    def expired_date
      return @expired_date if instance_variable_defined?(:@expired_date)

      keep_expired_days = YetiConfig.keep_expired_destinations_days
      @expired_date = keep_expired_days.days.ago if keep_expired_days.present?
    end
  end
end
