# frozen_string_literal: true

# == Schema Information
#
# Table name: destination_rate_policy
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  destination_rate_policy_name_key  (name) UNIQUE
#

class DestinationRatePolicy < ActiveRecord::Base
  has_many :destination, class_name: 'Routing::Destination'
  self.table_name = 'destination_rate_policy'
end
