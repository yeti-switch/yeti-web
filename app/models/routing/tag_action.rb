# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.tag_actions
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  tag_actions_name_key  (name) UNIQUE
#

class Routing::TagAction < ActiveRecord::Base
  self.table_name = 'class4.tag_actions'

  module CONST
    CLEAR_ID = 1
    REMOVE_ID = 2
    APPEND_ID = 3
    INTERSECTION_ID = 4

    freeze
  end

  def self.clear_action
    find(CONST::CLEAR_ID)
  end

  def display_name
    "#{name} | #{id}"
  end
end
