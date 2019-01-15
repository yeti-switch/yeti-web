# frozen_string_literal: true

module ActiveRecord
  module ConnectionAdapters
    module PostgreSQL
      module OID # :nodoc:
        class Inet < Type::String # :nodoc:
          def type
            :inet
          end
        end
      end
    end
  end
end
