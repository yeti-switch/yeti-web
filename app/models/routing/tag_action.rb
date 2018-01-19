# == Schema Information
#
# Table name: class4.tag_actions
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Routing::TagAction < ActiveRecord::Base
  self.table_name = 'class4.tag_actions'

  module CONST
    CLEAR_ID = 1.freeze
    REMOVE_ID = 2.freeze
    APPEND_ID = 3.freeze
    INTERSECTION_ID = 4.freeze

    freeze
  end

  def self.clear_action
    find(CONST::CLEAR_ID)
  end

  def display_name
    "#{name} | #{id}"
  end
end
