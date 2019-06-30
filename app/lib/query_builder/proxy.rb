# frozen_string_literal: true

module QueryBuilder
  class Proxy < ::QueryBuilder::Base
    def initialize(model_class)
      @model_class = model_class
      super()
    end

    private

    attr_reader :model_class

    def dup_params
      [model_class]
    end

    def query_values
      { includes: include_values, filters: filter_values, none: is_none }
    end

    def find_record(id)
      model_class.query_builder_find(id, query_values)
    end

    def find_collection
      return [] if is_none

      model_class.query_builder_collection(query_values)
    end
  end
end
