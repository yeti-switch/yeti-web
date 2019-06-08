# frozen_string_literal: true

module QueryBuilder
  class Proxy < ::QueryBuilder::Base
    def initialize(find_proc, collection_proc)
      @find_proc = find_proc
      @collection_proc = collection_proc
      super()
    end

    private

    attr_reader :find_proc, :collection_proc

    def dup_params
      [find_proc, collection_proc]
    end

    def query_values
      { includes: include_values, filters: filter_values, none: is_none }
    end

    def find_record(id)
      find_proc.call(id, query_values)
    end

    def find_collection
      return [] if is_none

      collection_proc.call(query_values)
    end
  end
end
