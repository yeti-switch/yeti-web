# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.load_balancers
#
#  id            :integer(2)       not null, primary key
#  name          :string           not null
#  signalling_ip :string           not null
#
# Indexes
#
#  load_balancers_name_key           (name) UNIQUE
#  load_balancers_signalling_ip_key  (signalling_ip) UNIQUE
#

class System::LoadBalancer < ApplicationRecord
  self.table_name = 'sys.load_balancers'

  include WithPaperTrail

  validates :name, :signalling_ip, presence: true
  validates :name, :signalling_ip, uniqueness: true

  after_save { self.class.increment_state_sequence }
  after_destroy { self.class.increment_state_sequence }

  def self.increment_state_sequence
    SqlCaller::Yeti.execute("SELECT nextval('sys.load_balancers_state_seq')")
  end

  def self.state_sequence
    SqlCaller::Yeti.select_value('SELECT last_value FROM sys.load_balancers_state_seq')
  end
end
