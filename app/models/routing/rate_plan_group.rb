# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.rate_plan_groups
#
#  id            :integer(4)       not null, primary key
#  rate_group_id :integer(4)       not null
#  rateplan_id   :integer(4)       not null
#
# Indexes
#
#  rate_plan_groups_rateplan_id_rate_group_id_idx  (rateplan_id,rate_group_id) UNIQUE
#
# Foreign Keys
#
#  rate_plan_groups_rate_group_id_fkey  (rate_group_id => rate_groups.id)
#  rate_plan_groups_rateplan_id_fkey    (rateplan_id => rateplans.id)
#
module Routing
  class RatePlanGroup < ApplicationRecord
    self.table_name = 'class4.rate_plan_groups'
  end
end
