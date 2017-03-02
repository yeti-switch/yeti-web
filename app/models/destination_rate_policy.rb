# == Schema Information
#
# Table name: destination_rate_policy
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class DestinationRatePolicy < ActiveRecord::Base
  has_many :destination
  self.table_name='destination_rate_policy'
end
