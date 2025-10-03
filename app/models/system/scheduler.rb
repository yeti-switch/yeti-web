# frozen_string_literal: true

# == Schema Information
#
# Table name: sys.schedulers
#
#  id               :integer(2)       not null, primary key
#  current_state    :boolean
#  enabled          :boolean          default(TRUE), not null
#  name             :string           not null
#  use_reject_calls :boolean          default(TRUE), not null
#
# Indexes
#
#  schedulers_name_key  (name) UNIQUE
#
class System::Scheduler < ApplicationRecord
  self.table_name = 'sys.schedulers'

  validates :name, uniqueness: { allow_blank: true }, presence: true

  has_many :customers_auths, class_name: 'CustomersAuth', foreign_key: 'scheduler_id', dependent: :nullify
  has_many :destination, class_name: 'Routing::Destination', foreign_key: 'scheduler_id', dependent: :nullify
  has_many :dialpeers, class_name: 'Dialpeer', foreign_key: 'scheduler_id', dependent: :nullify
  has_many :gateways, class_name: 'Gateway', foreign_key: 'scheduler_id', dependent: :nullify

  def display_name
    "#{name} | #{id}"
  end
end
