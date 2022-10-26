# frozen_string_literal: true

class ReadonlyValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _value)
    add_error(record, attribute) if record.persisted? && record.attribute_changed?(attribute)
  end

  private

  def add_error(record, attribute)
    message = options[:message] || :readonly
    record.errors.add(attribute, message, **error_options)
  end

  def error_options
    options.except(:message)
  end
end
