# == Schema Information
#
# Table name: sys.auth_log_tables
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  date_start :string           not null
#  date_stop  :string           not null
#  readable   :boolean          default(TRUE), not null
#  writable   :boolean          default(FALSE), not null
#  active     :boolean          default(TRUE), not null
#

class Cdr::AuthLogTable < Cdr::Base
  self.table_name = 'sys.auth_log_tables'

  include PgPartitioningMixin

  self.partitioned_model = Cdr::AuthLog
  self.partition_schema = 'auth_log'
  self.partition_key = :request_time
  self.partition_range = :day
  self.trigger_function_name = 'auth_log.auth_log_i_tgf'
  self.trigger_name = 'auth_log.auth_log_i_tg'

  has_paper_trail class_name: 'AuditLogItem', on: [:destroy, :touch, :update]

  scope :active, -> { where active: true }

  def display_name
    "#{self.name}"
  end

end
