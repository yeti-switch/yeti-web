# == Schema Information
#
# Table name: sys.sensor_levels
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class System::SensorLevel < Yeti::ActiveRecord
  self.table_name = 'sys.sensor_levels'


end
