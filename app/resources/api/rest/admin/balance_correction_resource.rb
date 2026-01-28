# frozen_string_literal: true

class Api::Rest::Admin::BalanceCorrectionResource < BaseResource
  singleton
  model_name 'Account'
  save_form 'AdminApi::AccountBalanceCorrectionForm'

  self._type = :balance_correction
  primary_key :id

  attributes :correction, :name, :balance

  def fetchable_fields
    super - %i[correction]
  end

  def self.updatable_fields(_context)
    %i[correction]
  end

  def self.creatable_fields(_context)
    %i[correction]
  end
end
