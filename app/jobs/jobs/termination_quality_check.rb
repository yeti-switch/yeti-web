# frozen_string_literal: true

module Jobs
  class TerminationQualityCheck < ::BaseJob
    self.cron_line = '*/16 * * * *'

    def execute
      # check quality for dialpeer
      Stats::TerminationQualityStat.dp_measurement.each do |stat|
        capture_job_extra(id: stat.id, class: stat.class.name) do
          dp = Dialpeer.find_by(id: stat.dialpeer_id)
          if dp.nil?
            logger.warn { "Statistic for removed dialpeer id #{stat.dialpeer_id}" }
          else
            DialpeerQualityCheck.new(dp).check_quality(stat)
          end
        end
      end

      # check quality for dialpeer
      Stats::TerminationQualityStat.gw_measurement.each do |stat|
        capture_job_extra(id: stat.id, class: stat.class.name) do
          gw = Gateway.find_by(id: stat.gateway_id)
          if gw.nil?
            logger.warn { "Statistic for removed gateway id #{stat.gateway_id}" }
          else
            GatewayQualityCheck.new(gw).check_quality(stat)
          end
        end
      end

      # check quality for destination
      Stats::TerminationQualityStat.dst_measurement.each do |stat|
        capture_job_extra(id: stat.id, class: stat.class.name) do
          dst = Routing::Destination.find_by(id: stat.destination_id)
          if dst.nil?
            logger.warn { "Statistic for removed destination id #{stat.destination_id}" }
          else
            DestinationQualityCheck.new(dst).check_quality(stat)
          end
        end
      end
    end
  end
end
