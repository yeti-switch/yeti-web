# frozen_string_literal: true

# == Schema Information
#
# Table name: delayed_jobs
#
#  id         :integer(4)       not null, primary key
#  attempts   :integer(4)       default(0), not null
#  failed_at  :datetime
#  handler    :text             not null
#  last_error :text
#  locked_at  :datetime
#  locked_by  :string(255)
#  priority   :integer(4)       default(0), not null
#  queue      :string(255)
#  run_at     :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  delayed_jobs_priority  (priority,run_at)
#

class BackgroundTask < ApplicationRecord
  self.table_name = 'delayed_jobs'
end
