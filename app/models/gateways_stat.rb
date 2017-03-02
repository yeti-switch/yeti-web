# == Schema Information
#
# Table name: gateways_stats
#
#  id             :integer          not null, primary key
#  gateway_id     :integer          not null
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
#

class GatewaysStat < ActiveRecord::Base
   belongs_to :gateway

end
