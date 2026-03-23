# frozen_string_literal: true

class ArrayInclusionValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
    values.each do |value|
      unless options[:in].include?(value)
        record.errors.add(attribute, :inclusion, **options.except(:in).merge!(value: value))
      end
    end
  end
end
