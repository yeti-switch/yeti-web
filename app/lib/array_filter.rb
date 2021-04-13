# frozen_string_literal: true

# Allows to filter array by multiple blocks with AND logic.
# Useful when blocks are generated dynamically.
# @example
#   filter = ArrayFilter.new
#   filter.add_filter { |item| item[:foo] == 1 }
#   filter.add_filter { |item| item[:bar] > 2 }
#   filter.call(items)
#   # same as
#   items.select { |item| item[:foo] == 1 && item[:bar] > 2 }
class ArrayFilter
  attr_reader :_filters

  def initialize
    @_filters = []
  end

  def add_filter(&block)
    @_filters.push(block)
    self
  end

  def call(items)
    items.select do |item|
      @_filters.all? { |filter_block| filter_block.call(item) }
    end
  end
end
