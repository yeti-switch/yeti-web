# frozen_string_literal: true

# Adds `<column>_within` scopes for inet columns: the column equals the given
# address or lies within the given network. ActiveAdmin can't infer a filter
# type for inet, so pages filter through these instead.
module InetWithinScopeable
  extend ActiveSupport::Concern

  class_methods do
    def inet_within_scopes(*columns)
      columns.each do |column|
        scope :"#{column}_within", lambda { |ip|
          begin
            IPAddr.new(ip)
          rescue IPAddr::Error
            return none
          end
          where("#{quoted_table_name}.#{connection.quote_column_name(column)} <<= ?::inet", ip)
        }
      end
    end
  end
end
