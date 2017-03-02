class AccountDecorator < BillingDecorator

  delegate_all
  decorates Account

  decorates_association :contractor, with: ContractorDecorator


  def decorated_balance
    money_format :balance
  end

  def decorated_min_balance
    min_balance_reached? ? h.content_tag(:font, money_format(:min_balance), color: :red) : money_format(:min_balance)
  end

  def decorated_max_balance
    max_balance_reached? ? h.content_tag(:font, money_format(:max_balance), color: :red) : money_format(:max_balance)
  end

  def decorated_display_name
    if min_balance_reached?||max_balance_reached?
      h.content_tag(:font,display_name, color: :red)
    elsif min_balance_close?||max_balance_close?
      h.content_tag(:font,display_name, color: :orange)
    else
      display_name
    end
  end

  def decorated_vendor_display_name
    if max_balance_reached?
      h.content_tag(:font,display_name, color: :red)
    elsif max_balance_close?
      h.content_tag(:font,display_name, color: :orange)
    else
      display_name
    end
  end

  def decorated_customer_display_name
    if min_balance_reached?
      h.content_tag(:font,display_name, color: :red)
    elsif min_balance_close?
      h.content_tag(:font,display_name, color: :orange)
    else
      display_name
    end
  end

end