# frozen_string_literal: true

class Equipment::Radius::Attribute < Yeti::ActiveRecord
  self.abstract_class = true

  # FORMATS = ['string', 'octets', 'ipaddr', 'integer', 'date', 'ifid', 'ipv6addr', 'ipv6prefix', 'abinary']
  FORMATS = %w[string octets ipaddr integer date ipv6addr].freeze

  TYPE_VALUE_MIN = 1
  TYPE_VALUE_MAX = 255

  validates :name, :type_id, :value, :format, presence: true
  validates :type_id, numericality: { greater_than_or_equal_to: TYPE_VALUE_MIN, less_than_or_equal_to: TYPE_VALUE_MAX, allow_nil: true, only_integer: true }
end
