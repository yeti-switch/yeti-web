# == Schema Information
#
# Table name: destination_rate_policy
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class DestinationRatePolicy < ActiveRecord::Base
  has_many :destination, class_name: 'Routing::Destination'
  self.table_name='destination_rate_policy'
end
