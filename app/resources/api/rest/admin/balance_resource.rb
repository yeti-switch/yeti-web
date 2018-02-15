class Api::Rest::Admin::BalanceResource < ::BaseResource
  attributes :balance

  model_name 'Account'
  self._type = :balances
  primary_key :external_id

  def self.updatable_fields(_context)
    [:balance]
  end

  def self.creatable_fields(_context)
    []
  end

  def _save
    _model.without_versioning do
      super
    end
  end

end
