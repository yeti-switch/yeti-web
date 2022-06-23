# frozen_string_literal: true

class BillingDecorator < ApplicationDecorator
  def money_format(attr)
    return nil if model.public_send(attr).nil?

    h.number_to_currency(model.public_send(attr), delimiter: ' ', separator: '.', precision: 2, unit: '')
  end

  def asr_format(attr)
    return nil if model.public_send(attr).nil?

    h.number_to_percentage(model.public_send(attr) * 100, precision: 2)
  end

  def cps_format(attr)
    model.public_send(attr).round(4)
  end

  def offered_load_format(attr)
    model.public_send(attr).round(4)
  end

  def acd_format(attr); end

  def time_format_min(attr)
    duration = model.public_send(attr)
    return '0 sec.' if duration.nil?

    if duration >= 60
      mins = duration.div(60).to_i
      secs = (duration - 60 * mins).to_i
      "#{mins} min. #{secs} sec."
    else
      "#{duration.to_i} sec."
    end
  end

  def time_format_min_dec(attr)
    duration = model.public_send(attr)
    h.number_to_currency(duration.to_f / 60, delimiter: ' ', separator: '.', precision: 2, unit: '')
  end

  def time_format_min_kolon(attr)
    duration = model.public_send(attr)
    return '00:00' if duration.nil?

    if duration >= 60
      mins = duration.div(60).to_i
      secs = (duration - 60 * mins).to_i
      "#{mins}:#{secs.to_s.rjust(2, '0')}"
    else
      "00:#{duration.to_s.rjust(2, '0')}"
    end
  end

  def time_format_min_i(attr)
    duration = model.public_send(attr).to_i
    return '0 sec.' if duration.nil?

    if duration >= 60
      mins = duration.div(60).to_i
      secs = (duration - 60 * mins).to_i
      "#{mins} min. #{secs} sec."
    else
      "#{duration} sec."
    end
  end

  def time_format(attr)
    secs = model.public_send(attr)
    [[60, :seconds], [60, :minutes], [24, :hours], [1000, :days]].map do |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    end.compact.reverse.join(' ')
  end
end
