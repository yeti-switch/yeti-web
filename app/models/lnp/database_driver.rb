# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.lnp_database_drivers
#
#  id          :integer          not null, primary key
#  name        :string           not null
#  description :text
#

class Lnp::DatabaseDriver < Yeti::ActiveRecord
  self.table_name = 'sys.lnp_database_drivers'

  def display_name
    name.to_s
  end

  SIP = 1
  THINQ = 2
  INMEMORY = 3
end
