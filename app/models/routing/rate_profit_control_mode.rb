# frozen_string_literal: true

# == Schema Information
#
# Table name: class4.rate_profit_control_modes
#
#  id   :integer(2)       not null, primary key
#  name :string           not null
#
# Indexes
#
#  rate_profit_control_modes_name_key  (name) UNIQUE
#

class Routing::RateProfitControlMode < ActiveRecord::Base
  self.table_name = 'class4.rate_profit_control_modes'
  def display_name
    name.to_s
  end
end
