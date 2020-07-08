# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.sensor_levels
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  sensor_levels_name_key  (name) UNIQUE
#

class System::SensorLevel < Yeti::ActiveRecord
  self.table_name = 'sys.sensor_levels'
end
