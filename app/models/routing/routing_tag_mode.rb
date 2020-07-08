# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.routing_tag_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  routing_tag_modes_name_key  (name) UNIQUE
#

class Routing::RoutingTagMode < Yeti::ActiveRecord
  self.table_name = 'class4.routing_tag_modes'

  module CONST
    OR = 0
    AND = 1

    freeze
  end

  after_initialize { readonly! }

  def and?
    id == CONST::AND
  end
end
