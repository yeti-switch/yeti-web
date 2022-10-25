# frozen_string_literal: true

class DialpeerQualityCheck
  include WithLogger

  def initialize(dialpeer)
    @dialpeer = dialpeer
  end

  def check_quality(quality_stat)
    return if dialpeer.locked?
    return unless low_quality?(quality_stat)

    ApplicationRecord.transaction do
      logger.warn { "Dialpeer id #{dialpeer.id} - Low quality" }
      dialpeer.update!(locked: true)
      NotificationEvent.dialpeer_locked(dialpeer, quality_stat)
    end
  end

  def unlock
    ApplicationRecord.transaction do
      dialpeer.update!(locked: false)
      NotificationEvent.dialpeer_unlocked(dialpeer)
    end
  end

  private

  attr_reader :dialpeer

  def low_quality?(quality_stat)
    quality_stat.acd < dialpeer.acd_limit || quality_stat.asr < dialpeer.asr_limit
  end
end
