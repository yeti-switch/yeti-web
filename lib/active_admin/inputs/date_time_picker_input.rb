# frozen_string_literal: true

module ActiveAdmin
  module DateTimePickerInputPatch
    def input_value(input_name = nil)
      val = object.public_send(input_name || method)
      if val.blank?
        val
      elsif column&.type == :date # column == NilClass object on rising validation errors from other (no datetime) fields
        val
      elsif column&.type == :string
        begin
          DateTime.parse(val).strftime(format)
        rescue StandardError
          val
        end
      else
        DateTime.new(val.year, val.month, val.day, val.hour, val.min, val.sec).strftime(format)
      end
    end
  end
end

ActiveAdmin::Inputs::DateTimePickerInput.prepend ActiveAdmin::DateTimePickerInputPatch
