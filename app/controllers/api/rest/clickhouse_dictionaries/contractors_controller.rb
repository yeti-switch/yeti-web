# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::ContractorsController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::Contractor.call
  end
end
