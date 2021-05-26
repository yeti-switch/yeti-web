# frozen_string_literal: true

module ActiveRecordFastCount
  extend ActiveSupport::Concern

  def fast_count(column_name = :all)
    # #count overrides the #select which could include generated columns referenced in #order,
    # so skip #order here, where it's irrelevant to the result anyway
    c = except(:select, :offset, :limit, :order)

    # Remove includes only if they are irrelevant
    # There is a bug that during reorder by raw sql AR adds schema name of table to references.
    # See https://github.com/rails/rails/issues/42331
    # Below 4 lines can be removed once issue being resolved for current version of rails
    schema_name = klass.table_name.split('.').first
    if c.references_values.include?(schema_name)
      c.references_values = c.references_values - [schema_name]
    end

    c = c.except(:includes) unless c.send(:references_eager_loaded_tables?)

    # .group returns an OrderedHash that responds to #count
    c = c.count(column_name)
    if c.is_a?(Hash) || c.is_a?(ActiveSupport::OrderedHash)
      c.count
    else
      c.respond_to?(:count) ? c.count(column_name) : c
    end
  end
end

ActiveRecord::Relation.include ActiveRecordFastCount
