# frozen_string_literal: true

# == Schema Information
#
# Table name: filter_types
#
#  id   :integer          not null, primary key
#  name :string
#

class FilterType < ActiveRecord::Base
  self.table_name = 'filter_types'
end
