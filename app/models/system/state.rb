# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.states
# Database name: primary
#
#  key   :string           not null, primary key
#  value :bigint(8)        default(0), not null
#
class System::State < ApplicationRecord
  self.primary_key = :key
  self.table_name = 'sys.states'
end
