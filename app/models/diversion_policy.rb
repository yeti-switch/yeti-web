# frozen_string_literal: true

# == Schema Information
#
# Table name: diversion_policy
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  diversion_policy_name_key  (name) UNIQUE
#

class DiversionPolicy < ActiveRecord::Base
  self.table_name = 'diversion_policy'
end
