# == Schema Information
#
# Table name: sys.config
#
#  id                          :integer          not null, primary key
#  call_duration_round_mode_id :integer          default(1), not null
#

class System::CdrConfig < Cdr::Base
  self.table_name ='sys.config'

  has_paper_trail class_name: 'AuditLogItem'


  belongs_to :call_duration_round_mode, class_name: 'System::CdrRoundMode', foreign_key: 'call_duration_round_mode_id'

  def display_name
    "#{self.id}"
  end

end
