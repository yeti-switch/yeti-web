# frozen_string_literal: true

# == Schema Information
#
# Table name: filter_types
#
#  id   :integer(4)       not null, primary key
#  name :string
#

class FilterType < ApplicationRecord
  self.table_name = 'filter_types'
end
