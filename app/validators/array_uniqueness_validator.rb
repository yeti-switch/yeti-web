# frozen_string_literal: true

class ArrayUniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
    record_error(record, attribute) if values.dup.uniq!.present?
  end

  private

  def record_error(record, attribute)
    record.errors.add(attribute, "can't contain duplicated values")
  end
end
