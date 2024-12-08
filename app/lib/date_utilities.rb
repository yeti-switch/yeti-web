# frozen_string_literal: true

module DateUtilities
  module_function

  def safe_datetime_parse(date_string)
    DateTime.parse(date_string)
  rescue ArgumentError, TypeError
    nil
  end
end
