# frozen_string_literal: true

# this patch needed for use `filter` option like in rails v8.0.1
# after update rails to version 8.0.1 and above this patch can be removed as well

module ActiveRecord
  module QueryMethods
    def in_order_of(column, values, filter: true)
      klass.disallow_raw_sql!([column], permit: connection.column_name_with_order_matcher)
      return spawn.none! if values.empty?

      references = column_references([column])
      self.references_values |= references unless references.empty?

      values = values.map { |value| type_caster.type_cast_for_database(column, value) }
      arel_column = column.is_a?(Symbol) ? order_column(column.to_s) : column

      scope = spawn.order!(build_case_for_value_position(arel_column, values, filter: filter))

      if filter
        where_clause = if values.include?(nil)
                         arel_column.in(values.compact).or(arel_column.eq(nil))
                       else
                         arel_column.in(values)
                       end

        scope = scope.where!(where_clause)
      end

      scope
    end

    def build_case_for_value_position(column, values, filter: true)
      node = Arel::Nodes::Case.new
      values.each.with_index(1) do |value, order|
        node.when(column.eq(value)).then(order)
      end

      node = node.else(values.length + 1) unless filter
      Arel::Nodes::Ascending.new(node)
    end
  end
end
