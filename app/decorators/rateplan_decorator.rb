# frozen_string_literal: true

class RateplanDecorator < BillingDecorator
  decorates Routing::Rateplan

  def rate_groups_links(newline: false)
    rate_groups = model.rate_groups.sort_by(&:name)
    return if rate_groups.empty?

    arbre do
      rate_groups.each do |rg|
        text_node h.link_to(rg.name, destinations_path(q: { rate_group_id_eq: rg.id }))
        newline ? br : text_node(' ')
      end
    end
  end

  def quality_alarm_emails(newline: false)
    emails = model.contacts.map(&:email).sort
    return if emails.empty?
    return emails.join(', ') unless newline

    arbre do
      emails.each do |email|
        text_node email
        br
      end
    end
  end
end
