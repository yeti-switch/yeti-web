# frozen_string_literal: true

class DestinationQualityCheck
  include WithLogger

  def initialize(destination)
    @destination = destination
  end

  def check_quality(quality_stat)
    return if destination.quality_alarm?
    return unless low_quality?(quality_stat)

    ApplicationRecord.transaction do
      logger.warn { "Destination id #{destination.id} - Low quality" }
      destination.update!(quality_alarm: true)
      NotificationEvent.destination_quality_alarm_fired(destination, quality_stat)
    end
  end

  def clear_quality_alarm
    ApplicationRecord.transaction do
      destination.update!(quality_alarm: false)
      NotificationEvent.destination_quality_alarm_cleared(destination)
    end
  end

  private

  attr_reader :destination

  def low_quality?(quality_stat)
    quality_stat.acd < destination.acd_limit || quality_stat.asr < destination.asr_limit
  end
end
