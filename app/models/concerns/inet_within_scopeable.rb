# frozen_string_literal: true

# Adds `<column>_within` scopes for inet columns: the column equals the given
# address or lies within the given network. ActiveAdmin can't infer a filter
# type for inet, so pages filter through these instead.
module InetWithinScopeable
  extend ActiveSupport::Concern

  class_methods do
    def inet_within_scopes(*columns)
      columns.each do |column|
        scope :"#{column}_within", lambda { |*values|
          return none unless values.size == 1

          begin
            addr = IPAddr.new(values.first)
          rescue IPAddr::Error
            return none
          end
          return none if addr.ipv6? && addr.zone_id

          where("#{quoted_table_name}.#{connection.quote_column_name(column)} <<= ?::inet", addr.cidr)
        }
      end
    end
  end
end
