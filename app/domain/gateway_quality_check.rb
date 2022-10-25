# frozen_string_literal: true

class GatewayQualityCheck
  include WithLogger

  def initialize(gateway)
    @gateway = gateway
  end

  def check_quality(quality_stat)
    return if gateway.locked?
    return unless low_quality?(quality_stat)

    ApplicationRecord.transaction do
      logger.warn { "Gateway id #{gateway.id} - Low quality" }
      gateway.update!(locked: true)
      NotificationEvent.gateway_locked(gateway, quality_stat)
    end
  end

  def unlock
    ApplicationRecord.transaction do
      gateway.update!(locked: false)
      NotificationEvent.gateway_unlocked(gateway)
    end
  end

  private

  attr_reader :gateway

  def low_quality?(quality_stat)
    quality_stat.acd < gateway.acd_limit || quality_stat.asr < gateway.asr_limit
  end
end
