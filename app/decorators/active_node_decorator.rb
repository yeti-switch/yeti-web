# frozen_string_literal: true

class ActiveNodeDecorator < Draper::Decorator
  delegate_all

  decorates RealtimeData::ActiveNode

  def safe_system_status
    @safe_system_status ||= model.system_status
  rescue StandardError => e
    Rails.logger.error { "(RtNode ##{model.id} Exception) <#{e.class}> #{e.message}" }
    CaptureError.capture(e, tags: { component: 'RealtimeData' }, extra: { rt_node_id: model.id })
    @safe_system_status = {}
  end

  def active_calls_count
    if safe_system_status.present?
      h.link_to(safe_system_status[:calls], h.active_calls_path(q: { node_id_eq: model.id }))
    end
  end

  def version
    safe_system_status[:version] if safe_system_status.present?
  end

  def shutdown_req_time
    safe_system_status[:shutdown_request_time] if safe_system_status.present?
  end

  def sessions_num
    safe_system_status[:sessions] if safe_system_status.present?
  end

  def uptime
    humanize_time_interval(safe_system_status[:uptime]) if safe_system_status.present?
  end

  def humanize_time_interval(seconds)
    return unless seconds

    seconds = seconds.round
    days, seconds = modal_int(seconds, 86_400)
    hours, seconds = modal_int(seconds, 3600)
    minutes, seconds = modal_int(seconds, 60)

    result = []
    result << "#{days} #{'day'.pluralize(days)} " if days > 0
    result << "#{hours.to_s.rjust(2, '0')}:"
    result << "#{minutes.to_s.rjust(2, '0')}:"
    result << seconds.to_s.rjust(2, '0').to_s

    result.join('')
  end

  def modal_int(value, base)
    return 0, value if value < base

    left = value % base
    [(value - left) / base, left]
  end
end
