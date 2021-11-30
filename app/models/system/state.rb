# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.states
#
#  key   :string           primary key
#  value :bigint(8)        default(0), not null
#
class System::State < ApplicationRecord
  self.primary_key = :key
  self.table_name = 'sys.states'
end
