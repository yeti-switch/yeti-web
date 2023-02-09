# frozen_string_literal: true

# == Schema Information
#
# Table name: ratemanagement.pricelist_states
#
#  id   :integer(4)       not null, primary key
#  name :string           not null
#
module RateManagement
  class PricelistState < ApplicationRecord
    self.table_name = 'ratemanagement.pricelist_states'

    module CONST
      STATE_ID_APPLIED = 10
      STATE_ID_DIALPEERS_DETECTED = 20
      STATE_ID_NEW = 30

      freeze
    end

    validates :name, presence: true

    scope :ordered, -> { order(id: :asc) }
  end
end
