# frozen_string_literal: true

module RoutingTagsSort
  module_function

  # @param routing_tag_ids [Array<Integer,nil>]
  # @example
  #
  #   RoutingTagsSort.call [1,3,nil,2] #=> [1,2,3,nil]
  #   RoutingTagsSort.call [1,nil,3,3,nil,2] #=> [1,2,3,nil]
  #
  def call(routing_tag_ids)
    routing_tag_ids.uniq.sort do |a, b|
      if a.nil?
        1
      elsif b.nil?
        -1
      else
        a <=> b
      end
    end
  end
end
