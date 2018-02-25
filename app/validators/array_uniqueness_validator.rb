class ArrayUniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
    if values.dup.uniq!.present?
      record_error(record, attribute)
    end
  end

  private

  def record_error(record, attribute)
    record.errors.add(attribute, "can't contain duplicated values")
  end
end
