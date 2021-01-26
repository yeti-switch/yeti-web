# frozen_string_literal: true

# == Schema Information
#
# Table name: session_refresh_methods
#
#  id    :integer(4)       not null, primary key
#  name  :string
#  value :string           not null
#

class SessionRefreshMethod < ApplicationRecord
  has_many :gateways
end
