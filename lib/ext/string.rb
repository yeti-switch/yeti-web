# frozen_string_literal: true

class String
  def to_bool
    return true if self == true || self =~ /(true|t|yes|y|1)$/i
    return false if self == false || blank? || self =~ /(false|f|no|n|0)$/i

    raise ArgumentError, "invalid value for Boolean: \"#{self}\""
  end
end
