class ArrayFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
    values.each do |value|
      if options[:with]
        if value.to_s !~ options[:with]
          record_error(record, attribute, :without, value)
        end
      elsif options[:without]
        if value.to_s =~ options[:without]
          record_error(record, attribute, :without, value)
        end
      end
    end
  end

  private

  def record_error(record, attribute, name, value)
    record.errors.add(attribute, :invalid, options.except(name).merge!(value: value))
  end
end
