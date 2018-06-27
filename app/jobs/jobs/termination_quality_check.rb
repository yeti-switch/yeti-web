module Jobs
  class TerminationQualityCheck < ::BaseJob

    def execute

      # check quality for dialpeer
      Stats::TerminationQualityStat.dp_measurement.each do |stat|
        dp=Dialpeer.find_by(id: stat.dialpeer_id)
        if dp.nil?
          logger.warn { "Statistic for removed dialpeer id #{stat.dialpeer_id}" }
        elsif !dp.locked? && (stat.acd<dp.acd_limit or stat.asr<dp.asr_limit)
          logger.warn { "Dialpeer id #{stat.dialpeer_id} - Low quality" }
          dp.fire_lock(stat)
        end
      end

      # check quality for dialpeer
      Stats::TerminationQualityStat.gw_measurement.each do |stat|
        gw=Gateway.find_by(id: stat.gateway_id)
        if gw.nil?
          logger.warn { "Statistic for removed gateway id #{stat.gateway_id}" }
        elsif !gw.locked? && (stat.acd<gw.acd_limit or stat.asr<gw.asr_limit)
          logger.warn { "Gateway id #{stat.gateway_id} - Low quality" }
          gw.fire_lock(stat)
        end
      end

      # check quality for destination
      Stats::TerminationQualityStat.dst_measurement.each do |stat|
        dst = Routing::Destination.find_by(id: stat.destination_id)
        if dst.nil?
          logger.warn { "Statistic for removed destination id #{stat.destination_id}" }
        elsif !dst.quality_alarm? && (stat.acd<dst.acd_limit or stat.asr<dst.asr_limit)
          logger.warn { "Destination id #{stat.destination_id} - Low quality" }
          dst.fire_alarm(stat)
        end
      end

    end


  end
end
