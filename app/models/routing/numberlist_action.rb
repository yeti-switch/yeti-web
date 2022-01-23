# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlist_actions
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  numberlist_actions_name_key  (name) UNIQUE
#

class Routing::NumberlistAction < ApplicationRecord
  self.table_name = 'class4.numberlist_actions'

  validates :name, presence: true, uniqueness: true
end
