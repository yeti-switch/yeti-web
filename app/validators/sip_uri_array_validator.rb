# frozen_string_literal: true

class SipUriArrayValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, values)
    values.each do |value|
      unless value.include?('<') && value.include?('>')
        record.errors.add(attribute, :invalid, value: value, message: "\"#{value}\" is not a valid SIP URI, must be enclosed in angle brackets e.g. <sip:host>")
        next
      end

      parsed = SipUriParser.parse(value)
      if parsed.nil? || parsed['s'].blank?
        record.errors.add(attribute, :invalid, value: value, message: "\"#{value}\" is not a valid SIP URI, must begin with sip:, sips: or tel: scheme")
      end
    end
  end
end
