# == Schema Information
#
# Table name: class4.rate_profit_control_modes
#
#  id   :integer          not null, primary key
#  name :string           not null
#

class Routing::RateProfitControlMode < ActiveRecord::Base

  self.table_name='class4.rate_profit_control_modes'
  def display_name
    "#{self.name}"
  end

end
