class GatewayDecorator < BillingDecorator

  delegate_all
  decorates Gateway

  decorates_association :contractor, with: ContractorDecorator

  def decorated_display_name
    if !enabled?
      h.content_tag(:font,display_name, color: :red)
    elsif locked?
      h.content_tag(:font,display_name, color: :orange)
    else
      display_name
    end
  end

  def decorated_termination_display_name
    if !enabled?||!allow_termination
      h.content_tag(:font,display_name, color: :red)
    elsif locked?
      h.content_tag(:font,display_name, color: :orange)
    else
      display_name
    end
  end

  def decorated_origination_display_name
    if !enabled?||!allow_origination
      h.content_tag(:font,display_name, color: :red)
    else
      display_name
    end
  end

end