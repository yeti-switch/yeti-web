# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.sensor_modes
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#

class System::SensorMode < Yeti::ActiveRecord
  self.table_name = 'sys.sensor_modes'

  # mode_id constants from this table
  IP_IP       = 1  # IP-IP encapsulation
  IP_ETHERNET = 2  # IP-Ethernet encapsulation
  HEPv3 = 3
end
