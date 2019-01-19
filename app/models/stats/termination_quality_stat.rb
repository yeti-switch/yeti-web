# frozen_string_literal: true

# == Schema Information
#
# Table name: stats.termination_quality_stats
#
#  id                  :integer          not null, primary key
#  dialpeer_id         :integer
#  gateway_id          :integer
#  time_start          :datetime         not null
#  success             :boolean          not null
#  duration            :integer          not null
#  pdd                 :float
#  early_media_present :boolean
#  destination_id      :integer
#

class Stats::TerminationQualityStat < Cdr::Base
  self.table_name = 'stats.termination_quality_stats'

  belongs_to :dialpeer, class_name: 'Dialpeer', foreign_key: :dialpeer_id
  belongs_to :gateway, class_name: 'Gateway', foreign_key: :gateway_id

  def self.total
    select("
      count(id) as count,
      count(nullif(duration<=#{GuiConfig.short_call_length},false)) as short_count,
      round(sum(duration)::numeric/60,4) as duration,
      round((sum(duration)::float/nullif(count(nullif(success,false)),0))::numeric/60,4) as acd,
      round((count(nullif(success,false))::float/nullif(count(id),0)::float)::numeric,4) as asr,
      max(pdd) as max_pdd,
      min(pdd) as min_pdd,
      #{GuiConfig.termination_stats_window}::integer as w
    ").where(
      "time_start>= now()-'? hours'::interval", GuiConfig.termination_stats_window
    ).reorder('').take
  end

  def self.dp_measurement
    select("
      count(id) as count,
      count(nullif(duration<=#{GuiConfig.short_call_length},false)) as short_count,
      round(sum(duration)::numeric/60,4) as duration,
      round((sum(duration)::float/nullif(count(nullif(success,false)),0))::numeric/60,4) as acd,
      round((count(nullif(success,false))::float/nullif(count(id),0)::float)::numeric,4) as asr,
      max(pdd) as max_pdd,
      min(pdd) as min_pdd,
      dialpeer_id").where(
        "time_start>= now()-'? hours'::interval and dialpeer_id is not null", GuiConfig.termination_stats_window
      ).group('dialpeer_id').having(
        'count(id)>=? AND sum(duration)>=?', min_calls_count, min_calls_duration
      ).reorder('')
  end

  def self.gw_measurement
    select("
      count(id) as count,
      count(nullif(duration<=#{GuiConfig.short_call_length},false)) as short_count,
      round(sum(duration)::numeric/60,4) as duration,
      round((sum(duration)::float/nullif(count(nullif(success,false)),0))::numeric/60,4) as acd,
      round((count(nullif(success,false))::float/nullif(count(id),0)::float)::numeric,4) as asr,
      max(pdd) as max_pdd,
      min(pdd) as min_pdd,
      gateway_id").where(
        "time_start>= now()-'? hours'::interval and gateway_id is not null", GuiConfig.termination_stats_window
      ).group('gateway_id').having(
        'count(id)>=? AND sum(duration)>=?', min_calls_count, min_calls_duration
      ).reorder('')
  end

  def self.dst_measurement
    select("
      count(id) as count,
      count(nullif(duration<=#{GuiConfig.short_call_length},false)) as short_count,
      round(sum(duration)::numeric/60,4) as duration,
      round((sum(duration)::float/nullif(count(nullif(success,false)),0))::numeric/60,4) as acd,
      round((count(nullif(success,false))::float/nullif(count(id),0)::float)::numeric,4) as asr,
      max(pdd) as max_pdd,
      min(pdd) as min_pdd,
      destination_id").where(
        "time_start>= now()-'? hours'::interval and destination_id is not null", GuiConfig.termination_stats_window
      ).group('destination_id').having(
        'count(id)>=? AND sum(duration)>=?', min_calls_count, min_calls_duration
      ).reorder('')
  end

  def self.pdd_distribution
    select('pdd::integer, count(id)').where(
      "time_start>= now()-'? hours'::interval", GuiConfig.termination_stats_window
    ).where(success: true).group('pdd::integer').order('pdd::integer ASC')
  end

  def self.pdd_distribution_pluck
    pdd_distribution.pluck('pdd::integer', 'count(id)')
  end

  def self.min_calls_count
    @min_calls_count ||= GuiConfig.quality_control_min_calls
  end

  def self.min_calls_duration
    @min_calls_duration ||= GuiConfig.quality_control_min_duration
  end

  def self.to_pdd_gateway_chart(id, options = {})
    to_chart(where(gateway_id: id).pdd_distribution_pluck, 'PDD', options)
  end

  def self.to_pdd_dialpeer_chart(id, options = {})
    to_chart(where(dialpeer_id: id).pdd_distribution_pluck, 'PDD', options)
  end

  def self.to_chart(data, title, options = {})
    [{
      key: title,
      area: true,
      values: data.map { |el| { x: el[0], y: el[1] } }
    }.merge(options)]
  end
end
