class ApiAccessDecorator < Draper::Decorator
  decorates System::ApiAccess
  delegate_all

  def allowed_ips
    model.formtastic_allowed_ips
  end

  def account_ids
    model.account_ids.join(', ')
  end
end
