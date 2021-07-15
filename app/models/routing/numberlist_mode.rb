# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.numberlist_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  blacklist_modes_name_key  (name) UNIQUE
#

class Routing::NumberlistMode < ApplicationRecord
  self.table_name = 'class4.numberlist_modes'
end
