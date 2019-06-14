# frozen_string_literal: true

class YetiDateTimeType < ActiveModel::Type::Value
  def type
    :datetime
  end

  private

  def cast_value(value)
    return if value.blank? || value.zero?

    DateTime.strptime(value.to_s.split('.')[0], '%s').in_time_zone
  end
end

ActiveModel::Type.register :yeti_date_time, YetiDateTimeType
