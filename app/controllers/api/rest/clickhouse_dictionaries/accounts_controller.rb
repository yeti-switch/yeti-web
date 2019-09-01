# frozen_string_literal: true

class Api::Rest::ClickhouseDictionaries::AccountsController < ::Api::RestController
  def index
    render plain: ClickhouseDictionary::Account.call
  end
end
