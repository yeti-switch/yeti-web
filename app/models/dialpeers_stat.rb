# == Schema Information
#
# Table name: dialpeers_stats
#
#  dialpeer_id    :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  calls          :integer          not null
#  calls_success  :integer          not null
#  calls_fail     :integer          not null
#  total_duration :integer          not null
#  asr            :float
#  acd            :float
#  locked_at      :datetime
#  unlocked_at    :datetime
#  id             :integer          not null, primary key
#

class DialpeersStat < ActiveRecord::Base
  belongs_to :dialpeer

end
