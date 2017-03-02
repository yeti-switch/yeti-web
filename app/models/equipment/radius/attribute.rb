class Equipment::Radius::Attribute < Yeti::ActiveRecord

  self.abstract_class = true

  #FORMATS = ['string', 'octets', 'ipaddr', 'integer', 'date', 'ifid', 'ipv6addr', 'ipv6prefix', 'abinary']
  FORMATS = ['string', 'octets', 'ipaddr', 'integer', 'date', 'ipv6addr' ]

  TYPE_VALUE_MIN=1
  TYPE_VALUE_MAX=255

  validates_presence_of :name, :type_id, :value, :format
  validates_numericality_of :type_id, greater_than_or_equal_to: TYPE_VALUE_MIN, less_than_or_equal_to: TYPE_VALUE_MAX, allow_nil: true, only_integer: true
end
