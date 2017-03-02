# == Schema Information
#
# Table name: diversion_policy
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class DiversionPolicy < ActiveRecord::Base
  self.table_name = 'diversion_policy'
end
