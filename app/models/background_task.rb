# == Schema Information
#
# Table name: delayed_jobs
#
#  id         :integer          not null, primary key
#  priority   :integer          default(0), not null
#  attempts   :integer          default(0), not null
#  handler    :text             not null
#  last_error :text
#  run_at     :datetime
#  locked_at  :datetime
#  failed_at  :datetime
#  locked_by  :string(255)
#  queue      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BackgroundTask < ActiveRecord::Base
  self.table_name = "delayed_jobs"


end
