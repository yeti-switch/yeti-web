# frozen_string_literal: true

class Api::Rest::Dns::ZonesController < Api::Rest::Dns::BaseController
  def zonefile
    render plain: zonefile_payload(zone), content_type: 'text/dns'
  end

  private

  def zone
    @zone ||= Equipment::Dns::Zone.includes(:records).find(params[:id])
  end

  def zonefile_payload(zone)
    lines = []
    lines << '$ORIGIN .'
    lines << "$TTL #{zone.minimum}"
    lines << '; SOA Record'
    lines << "#{zone.name} IN SOA #{zone.soa_mname} #{zone.soa_rname} ("
    lines << "  #{zone.serial} ; serial"
    lines << "  #{zone.refresh} ; refresh (#{human_duration(zone.refresh)})"
    lines << "  #{zone.retry} ; retry (#{human_duration(zone.retry)})"
    lines << "  #{zone.expire} ; expire (#{human_duration(zone.expire)})"
    lines << "  #{zone.minimum} ; minimum (#{human_duration(zone.minimum)})"
    lines << ')'
    lines << ''
    lines << "$ORIGIN #{zone.name}."
    lines << ''

    grouped_records = zone.records.sort_by(&:id).group_by(&:record_type)
    grouped_records.each do |record_type, records|
      lines << "; #{record_type} Record"
      records.each do |record|
        lines << "#{record.name} #{record.record_type} #{record.content}"
      end
      lines << ''
    end

    "#{lines.join("\n")}\n"
  end

  def human_duration(total_seconds)
    seconds = total_seconds.to_i
    return '0 seconds' if seconds.zero?

    units = [
      ['week', 1.week.to_i],
      ['day', 1.day.to_i],
      ['hour', 1.hour.to_i],
      ['minute', 1.minute.to_i],
      ['second', 1]
    ]

    parts = []
    units.each do |name, size|
      next if seconds < size

      value, seconds = seconds.divmod(size)
      suffix = value == 1 ? '' : 's'
      parts << "#{value} #{name}#{suffix}"
    end

    parts.join(' ')
  end
end
