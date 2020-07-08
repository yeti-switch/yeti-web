# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.api_log_config
#
#  id         :integer(4)       not null, primary key
#  controller :string           not null
#  debug      :boolean          default(FALSE), not null
#
# Indexes
#
#  api_log_config_controller_key  (controller) UNIQUE
#

class System::ApiLogConfig < ActiveRecord::Base
  self.table_name = 'sys.api_log_config'

  has_paper_trail class_name: 'AuditLogItem'

  def debug?
    !!debug
  end
end
