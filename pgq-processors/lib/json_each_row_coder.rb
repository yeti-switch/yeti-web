# frozen_string_literal: true

require 'json'

module JsonEachRowCoder
  module_function

  def dump(rows, time_fields: [], date_fields: [])
    formatted_rows = rows.map do |row|
      formatted_row = format_row(row, time_fields: time_fields, date_fields: date_fields)
      JSON.dump(formatted_row)
    end
    formatted_rows.join("\n")
  end

  alias encode dump

  def load(text)
    text.split("\n").map { |line| JSON.parse(line) }
  end

  alias decode load

  def format_row(row, time_fields: [], date_fields: [])
    formatted_row = {}
    row.each do |key, value|
      value = format_timestamp(value) if time_fields.include?(key)
      value = format_date(value) if date_fields.include?(key)
      value = format_boolean(value) if [true, false].include?(value)
      formatted_row[key] = value
    end
    formatted_row
  end

  def format_timestamp(value)
    return if value.nil?

    DateTime.parse(value).new_offset(0).strftime('%Y-%m-%d %H:%M:%S')
  end

  def format_date(value)
    return if value.nil?

    DateTime.parse(value).new_offset(0).strftime('%Y-%m-%d')
  end

  def format_boolean(value)
    return if value.nil?

    value ? 1 : 0
  end
end
