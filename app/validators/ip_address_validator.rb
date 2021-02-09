# frozen_string_literal: true

class IpAddressValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    IPAddr.new(value)
  rescue IPAddr::Error => _error
    record.errors.add attribute, 'is not valid'
  end
end
