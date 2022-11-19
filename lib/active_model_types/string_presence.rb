# frozen_string_literal: true

# Simplified array type that works similar to ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array
# but for ActiveModel.
# @see WithActiveModelArrayAttribute
class StringPresence < ActiveModel::Type::String
  private

  def cast_value(value)
    super.presence
  end
end

ActiveModel::Type.register :string_presence, StringPresence
ActiveRecord::Type.register :string_presence, StringPresence
