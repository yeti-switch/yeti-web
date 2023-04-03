# frozen_string_literal: true

class RequiredWithValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, _values)
    is_both_direction = options[:both_direction]
    is_both_direction = true if is_both_direction.nil?
    attr_second_value = record.public_send(options[:with])
    attr_second_name = options[:with]
    attr_main_value = record.public_send(attribute)
    attr_main_name = attribute

    return false if attr_second_value.nil? && attr_main_value.nil?

    if not_set?(attr_second_value)
      record.errors.add(attr_main_name, "must be changed together with #{attr_second_name.to_s.humanize}")
    elsif not_set?(attr_second_value)
      record.errors.add(attr_main_name, "must be changed together with #{attr_second_name.to_s.humanize}")
    elsif not_set?(attr_main_value) && is_both_direction
      record.errors.add(attr_second_name, "must be changed together with #{attr_main_name.to_s.humanize}")
    end
  end

  def not_set?(attr)
    attr.nil? || (attr.is_a?(String) && attr.empty?)
  end
end
