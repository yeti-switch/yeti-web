# frozen_string_literal: true

class CdrExportDecorator < ApplicationDecorator
  def time_format_with_hint
    h.with_tooltip(display_hint_for_time_format) { status_tag model.time_format }
  end

  def display_name
    "CDR Export ##{model.id}"
  end

  private

  def display_hint_for_time_format
    case model.time_format
    when CdrExport::WITH_TIMEZONE_TIME_FORMAT
      'Example: 2025-02-03 20:21:32.118457+00'
    when CdrExport::WITHOUT_TIMEZONE_TIME_FORMAT
      'Example 2025-02-03 20:21:32.118457'
    when CdrExport::ROUND_TO_SECONDS_TIME_FORMAT
      'Example 2025-02-03 20:21:32'
    else
      ''
    end
  end
end
