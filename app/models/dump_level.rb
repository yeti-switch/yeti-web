# == Schema Information
#
# Table name: dump_level
#
#  id      :integer          not null, primary key
#  name    :string           not null
#  log_sip :boolean          default(FALSE), not null
#  log_rtp :boolean          default(FALSE), not null
#

class DumpLevel < ActiveRecord::Base
  self.table_name = 'dump_level'

end
