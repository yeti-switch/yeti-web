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

class System::ApiLogConfig < ApplicationRecord
  self.table_name = 'sys.api_log_config'

  include WithPaperTrail

  def debug?
    !!debug
  end
end
