# == Schema Information
#
# Table name: session_refresh_methods
#
#  id    :integer          not null, primary key
#  value :string           not null
#  name  :string
#

class SessionRefreshMethod < ActiveRecord::Base
  has_many :gateways

end
