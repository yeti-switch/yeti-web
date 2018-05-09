# == Schema Information
#
# Table name: class4.routing_tag_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Routing::RoutingTagMode < Yeti::ActiveRecord
  self.table_name='class4.routing_tag_modes'

  module CONST
    OR = 0.freeze
    AND = 1.freeze

    freeze
  end

  after_initialize { readonly! }

  def and?
    id == CONST::AND
  end
end
