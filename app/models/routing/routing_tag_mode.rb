class Routing::RoutingTagMode < Yeti::ActiveRecord
  self.table_name='class4.routing_tag_modes'

  module CONST
    OR = 0.freeze
    AND = 1.freeze

    freeze
  end

  after_initialize { readonly! }
end
